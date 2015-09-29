module NepaliCalendar
  class BsCalendar < NepaliCalendar::Calendar

    MONTHNAMES = %w{nil Baisakh Jestha Ashad Shrawn Bhadra Ashwin Kartik Mangshir Poush Magh Falgun Chaitra}
    DAYNAMES = %w{nil Aitabar Sombar Mangalbar Budhbar Bihibar Sukrabar Sanibar}

    class << self
      def ad_to_bs(year, month, day)
        fail 'Invalid date!' unless valid_date?(year, month, day)

        ref_day_eng = get_ref_day_eng
        date_ad = Date.parse("#{year}/#{month}/#{day}")
        return unless date_in_range?(date_ad, ref_day_eng)

        days = total_days(date_ad, ref_day_eng)
        get_bs_date(days, ref_date['ad_to_bs']['bs'])
      end

      def get_bs_date(days, ref_day_nep)
        wday = 7
        year, month, day = ref_day_nep.split('/').map(&:to_i)
        travel days, year: year, month: month, day: day, wday: wday
      end

      def today
        date = Date.today
        ad_to_bs(date.year, date.month, date.day)
      end
    end

    def beginning_of_week
      date = {year: year, month: month, day: day, wday: wday}
      days = (wday > 1) ? -(wday - 1) : 0
      NepaliCalendar::BsCalendar.travel days, date
    end

    def end_of_week
      date = {year: year, month: month, day: day, wday: wday}
      days = (wday < 7) ? (7 - wday) : 0
      NepaliCalendar::BsCalendar.travel days, date
    end

    def beginning_of_month
      date = {year: year, month: month, day: day, wday: wday}
      days = -(day - 1)
      NepaliCalendar::BsCalendar.travel days, date
    end

    def end_of_month
      date = {year: year, month: month, day: day, wday: wday}
      days = month_days(year, month) - day
      NepaliCalendar::BsCalendar.travel days, date
    end

    private

      def self.travel days, option = {}
        return if days.nil? && days.zero?

        if days < 0
          option = travel_backward(days, option)
        else
          option = travel_forward(days, option)
        end
        NepaliCalendar::BsCalendar.date_object(option)
      end

      def self.travel_forward days, option = {}
        year = option[:year]
        month = option[:month]
        day = option[:day]
        wday = option[:wday]

        while days != 0
          bs_month_days = NepaliCalendar::BS[year][month]
          day += 1
          wday += 1
          wday = 1 if wday > 7

          if day > bs_month_days
            month += 1
            day = 1
          end

          if month > 12
            year += 1
            month = 1
          end

          days -= 1
        end
        option = {year: year, month: month, day: day, wday: wday}
      end

      def self.travel_backward days, option = {}
        year = option[:year]
        month = option[:month]
        day = option[:day]
        wday = option[:wday]

        while days != 0
          bs_month_days = NepaliCalendar::BS[year][month - 1]
          day -= 1
          wday -= 1
          wday = 7 if wday < 1

          if day < 1
            month -= 1
            day = bs_month_days
          end

          if month < 1
            year -= 1
            month = 12
          end

          days += 1
        end
        option = {year: year, month: month, day: day, wday: wday}
      end

      def self.date_object date
        month_name = MONTHNAMES[date[:month]]
        wday_name = DAYNAMES[date[:wday]]
        option = { year: date[:year], month: date[:month], day: date[:day],
          wday: date[:wday], month_name: month_name, wday_name: wday_name }
        new('', option)
      end

      def self.get_ref_day_eng
         Date.parse(ref_date['ad_to_bs']['ad'])
      end

      def get_year_from_days days
        days/365
      end

      def month_days(year, month)
         NepaliCalendar::BS[year][month]
      end
  end
end
