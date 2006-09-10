module Contests::BaseHelper
  def update_page_new_form(contest, choice)
    page.replace_html 'contest-messages', ''
    page.replace_html 'contest-edit-window-left', :partial => "contests/#{contest.class.to_s.downcase}/edit", :locals => { :contest => contest, :choice => choice }
    page.replace_html 'contest-edit-window-right', :partial => "contests/#{contest.class.to_s.downcase}/preview", :locals => { :contest => contest }
    page.show('contest-edit-window')
    page << "document.getElementById('contest-edit-window').style.visibility = 'visible'"
  end
end
