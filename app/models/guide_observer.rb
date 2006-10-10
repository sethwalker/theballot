class GuideObserver < ActiveRecord::Observer
  def before_update(guide)
    if guide.c3? && guide.approved? && !guide.diff.reject{|k,v| [:updated_at].include?(k)}.empty?
      GuidePromoter.deliver_change_notification(guide)
    end
  end
end
