class TheBallot
  DEFAULT_DATE = Time.mktime(2008, 11, 4)
  ADMIN_EMAIL = 'voterguides@theleague.com'
  SYSTEM_FROM_EMAIL = 'voterguides@theleague.com'
  TECH_ADMIN_EMAIL = %w(seth@indyvoter.org voterguides@theleague.com)
  ATTACHMENT_SIZE_LIMIT = 1.megabytes
  GUIDES_STAY_CURRENT_FROM = 1.week.ago
  GUIDES_PER_LIST_PAGE = 35

  # past per-page can be 0 to keep past guides off homepage
  GUIDES_PER_PAST_LIST_PAGE = 20
  SHOW_PAST_GUIDES_ON_HOMEPAGE = FALSE
end

#TODO: Check that the exception email works when you deploy onto production
ExceptionNotifier.exception_recipients = TheBallot::TECH_ADMIN_EMAIL
ExceptionNotifier.email_prefix = "[VOTERGUIDE ERROR] "
