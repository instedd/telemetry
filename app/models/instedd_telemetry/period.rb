module InsteddTelemetry
  class Period < ActiveRecord::Base

    def already_finished?
      self.end < Time.now
    end

    def stats_already_sent?
      !stats_sent_at.nil?
    end

    def self.span
      1.week
    end

    def self.current
      now = DateTime.now
      last_period = Period.last

      if last_period.present?
        if now < last_period.end
          last_period
        else
          current_beginning = last_period.end
          current_end = current_beginning + span

          until now < current_end
            current_beginning = current_end
            current_end = current_beginning + span
          end
          
          create({beginning: current_beginning, end: current_end})
        end
      else
        create({beginning: now, end: now + span})
      end
    end

    def self.lock_for_upload
      now = Time.now
      lock_owner = SecureRandom.uuid
      lock_expiration = now + 15.minutes

      locked_count = self.where("stats_sent_at IS NULL AND end < ?", now)
                         .where("lock_owner IS NULL OR lock_expiration < ?", now)
                         .update_all(lock_owner: lock_owner, lock_expiration: lock_expiration)

      if locked_count > 0
        periods = self.where("lock_owner = ?", lock_owner)
        yield periods
        periods.update_all(lock_owner: nil, lock_expiration: nil)
      else
        yield []
      end
    end

  end

end
