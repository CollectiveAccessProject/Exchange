class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    @resources = Resource.where(user_id: current_user.id)

    # user activity history
    activity_history = PaperTrail::Version.where('whodunnit = ?', current_user.id).order(:created_at => :desc).limit(20)

    @activity_history = []
    activity_history.each do |h|
      is_delete = false

      created_at = h.created_at
      if (!h.item)
        created_at = h.created_at
        is_delete = true
        item = h.reify
      else
        item = h.item
      end

      next if (!item)

      event_disp = (is_delete) ? "deleted" : h.event + "d"
      event_disp[0] = event_disp[0].capitalize

      item_type = h.item_type.downcase

      case(item_type)
        when 'resource'
          t = item.title
          item_type_disp = item.resource_type_for_display
        when 'mediafile'
          t = item.slug
          item = item.resource
          item_type_disp = "Media"
        else
          next
      end

      @activity_history.push({event: event_disp, title: t, item: item, item_type: item_type_disp, datetime: created_at.strftime("%m/%d/%y at %H:%M:%S"), created_at: created_at, deleted: is_delete})


      # user favorites
      @favorites = Favorite.where(user_id: current_user.id)
  end

  end
end
