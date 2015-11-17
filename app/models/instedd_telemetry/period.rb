module InsteddTelemetry
  class Period < BaseModel
    LOCK_TIME = 1.hour

    def already_finished?
      self.end < Time.now
    end

    def stats_already_sent?
      !stats_sent_at.nil?
    end

    def self.span
      InsteddTelemetry.configuration.period_size
    end

    def self.current
      ensure_periods_exist
      Period.order("beginning DESC").first
    end

    #
    # Looks up the last period record present in the database and creates a new one
    # for every other that should exist between that date and the present time.
    #
    def self.ensure_periods_exist
      now = Time.now
      last_period = Period.order("beginning DESC").first

      if last_period.present?
        if now < last_period.end
          last_period
        else
          current_beginning = last_period.end
          current_end = current_beginning + span

          until now < current_end
            create({beginning: current_beginning, end: current_end})
            
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
      lock_expiration = now + LOCK_TIME

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
