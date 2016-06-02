require 'minitest/autorun'
require 'eml_to_pdf'

class MiniTest::Test
  TEST_FOLDER_PATH = Pathname.new(File.expand_path(__dir__))

  def email_fixture_path(name)
    fixture_path(name + ".eml", :emails)
  end

  def fixture_path(name, subfolder = "")
    (TEST_FOLDER_PATH + "fixtures" + subfolder.to_s + name).to_s
  end

  def fixture(name, subfolder = "")
    File.read(fixture_path(name, subfolder))
  end
end
