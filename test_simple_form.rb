#require_relative "simple_web_form"
require 'selenium-webdriver'
require 'test/unit'

class TestSimpleForm < Test::Unit::TestCase
  # Declaring Constant Variables
  URL = 'https://docs.google.com/forms/d/e/1FAIpQLSeT6MPuoZm8Ks3TUw9j3lTKeUlwvcVseFeear6OF4ey24Q40g/viewform?fbzx=2035746817447183293'
  WAIT = Selenium::WebDriver::Wait.new(:timeout => 5)


  # Declaring Global Variables
  $yes_check_xpath = ".//*[@id='group_310473641_1']"
  $no_check_xpath = ".//*[@id='group_310473641_2']"
  $name = 'bob'
  $drop_down_opt = 'Cucumber'
  $comments_msg = 'Cucumber is so awesome! Thank you.'
  $expected_success_response = 'Your response has been recorded.'
  $expected_error_response = 'This is a required question'


  #
  # Overriding setup function to initialize chrome web driver
  #
  def setup
    @driver = Selenium::WebDriver.for :chrome
    @driver.navigate.to URL
  end


  #
  # Overriding teardown function to terminate the browser after each test case
  #
  def teardown
    @driver.quit
    @drive = nil
  end


  #
  # Below are Common Helper Functions for test cases. Enables modularization,
  # reduces code duplication
  #
  def add_name_input(name)
    name_input = WAIT.until {
      element = @driver.find_element(:xpath, ".//*[@id='entry_1041466219']")
      element if element.displayed?
    }
    name_input.send_keys(name)
  end

  def click_check_box(check_box_id)
    yes_check = WAIT.until {
      element = @driver.find_element(:xpath, check_box_id)
      element if element.displayed?
    }
    yes_check.click
  end

  def select_from_drop_down(option)
    drop_down = WAIT.until {
      element = @driver.find_element(:xpath, ".//*[@id='entry_262759813']")
      element if element.displayed?

    }
    options = drop_down.find_elements(:tag_name=>'option')
    options.each do |g|
      if g.text == option
        g.click
        break
      end
    end
  end

  def enter_comments_input(comments)
    name_input = WAIT.until {
      element = @driver.find_element(:xpath, ".//*[@id='entry_649813199']")
      element if element.displayed?
    }
    name_input.send_keys(comments)
  end

  def click_submit_button
    submit = WAIT.until {
      element = @driver.find_element(:id, 'ss-submit')
      element if element.displayed?
    }
    submit.click
  end

  def validate_submission
    WAIT.until {
      element = @driver.find_element(:xpath, "//div[@class='ss-resp-message']")
      element if element.displayed?
    }
  end

  def validate_submission_error
    assert_equal( false, @driver.find_element(:xpath, ".//*[@id='ss-form']/ol/div[1]/div/div/div[1]").displayed?)
    assert_equal( false, @driver.find_element(:xpath, ".//*[@id='ss-form']/ol/div[1]/div/div/div[2]").displayed?)
    assert_equal( false, @driver.find_element(:xpath, ".//*[@id='ss-form']/ol/div[2]/div/div/div[1]").displayed?)

    WAIT.until {
      element = @driver.find_element(:xpath, ".//*[@id='ss-form']/ol/div[2]/div/div/div[2]")
      element if element.displayed?
    }
  end


  #
  # Test Case - test_happy_path_case [Positive Test Case]
  #
  # successfully submits form with valid and complete inputs for the form
  #
  def test_happy_path_case
    add_name_input($name)

    click_check_box($yes_check_xpath)

    assert_equal( true, @driver.find_element(:xpath, $yes_check_xpath).selected?)
    assert_equal( false, @driver.find_element(:xpath, $no_check_xpath).selected?)

    select_from_drop_down($drop_down_opt)

    enter_comments_input($comments_msg)

    click_submit_button

    assert_equal($expected_success_response, validate_submission.text)
  end


  #
  # Test Case - test_incomplete_form_case [Negative Test Case]
  #
  # fails to submits form with yes and no check boxes left blank, validates
  # error text and error tag visibilities
  #
  def test_incomplete_form_case

    add_name_input($name)

    assert_equal( false, @driver.find_element(:xpath, $yes_check_xpath).selected?)
    assert_equal( false, @driver.find_element(:xpath, $no_check_xpath).selected?)

    select_from_drop_down($drop_down_opt)

    enter_comments_input($comments_msg)

    click_submit_button

    assert_equal($expected_error_response, validate_submission_error.text)
  end
end