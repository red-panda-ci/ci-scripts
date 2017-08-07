require 'bddfire'

# Load config
require 'yaml'
$config = YAML.load_file("config.yml")
puts($config.inspect)

def navigate_to(page)
  visit($config['baseurl'] + page)
end

Given(/^I am on the "([^"]*)" page$/) do |page|
  navigate_to(page)
end

When(/^I wait for "(.*?)" element to dissapear$/) do |element|
  expect(page).not_to have_css(element)
end

When(/^I wait for (\d+) seconds$/) do |arg1|
  sleep arg1.to_i
end

Then(/^I check the checkbox with id "(.*?)"$/) do |boxid|
   find(:xpath,"//*[@id='#{boxid}']").set(true)
end

Then(/^I uncheck the checkbox with id "(.*?)"$/) do |boxid|
   find(:xpath,"//*[@id='#{boxid}']").set(false)
end

Then(/^I click the (\d+) instance of "(.*?)"$/) do |instance, link|
   page.all(:xpath,"//*[text()='#{link}']")[instance.to_i - 1].click
end

Then(/^I click the (\d+) css element of "(.*?)" class$/) do |instance, cssclass|
   page.all(:css, cssclass)[instance.to_i - 1].click
end

Then(/^I click the css element "(.*?)"$/) do |cssclass|
   find(:css, cssclass).click
end

Then(/^I dump the page$/) do ||
   print page.html
end
