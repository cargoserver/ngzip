require_relative "../../test_helper"

describe Ngzip do

  it "must define a version" do
    Ngzip::VERSION.wont_be_nil
  end

end