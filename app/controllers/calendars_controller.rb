class CalendarsController < ApplicationController
  def index
    @today = Date.current
    @month_date = requested_month || @today.beginning_of_month
    @month_label = @month_date.strftime("%Y年%-m月")
    @days_in_month = @month_date.end_of_month.day
    @leading_blank_cells = @month_date.wday
    @total_cells = ((@leading_blank_cells + @days_in_month) / 7.0).ceil * 7
    @prev_month_param = (@month_date - 1.month).strftime("%Y-%m")
    @next_month_param = (@month_date + 1.month).strftime("%Y-%m")
  end

  private

  def requested_month
    return if params[:month].blank?

    Date.strptime(params[:month], "%Y-%m").beginning_of_month
  rescue ArgumentError
    nil
  end
end
