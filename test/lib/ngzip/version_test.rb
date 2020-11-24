# frozen_string_literal: true

require_relative '../../test_helper'

describe Ngzip do
  it 'must define a version' do
    expect(Ngzip::VERSION).wont_be_nil
  end
end
