require_relative "../../test_helper"
require 'uri'
require 'pathname'

describe Ngzip do

  it 'must support the static method :build' do
    expect(Ngzip.respond_to?(:build)).must_equal true
  end

end

describe Ngzip::Builder do

  def encode_file_path(path)
    ERB::Util.url_encode path
  end

  let(:builder) { Ngzip::Builder.new() }
  let(:lorem) { File.expand_path('../../../data/a/lorem.txt', __FILE__) }
  let(:ipsum) { File.expand_path('../../../data/a/ipsum.txt', __FILE__) }
  let(:without_dot) { File.expand_path('../../../data/a/filename-without-a-dot', __FILE__) }
  let(:my_file) { File.expand_path('../../../data/a/d/my_file.txt', __FILE__) }
  let(:whitespaced) { File.expand_path('../../../data/a/A filename with whitespace.txt', __FILE__) }
  let(:plused) { File.expand_path('../../../data/c/A filename with space and + in it.txt', __FILE__) }
  let(:cargo) { File.expand_path('../../../data/b/Cargo.png', __FILE__) }
  let(:sit) { File.expand_path('../../../data/sit.txt', __FILE__) }
  let(:a) { File.expand_path('../../../data/a', __FILE__) }
  let(:questions) { File.expand_path('../../../data/c/questions?', __FILE__) }

  it 'must be defined' do
    Ngzip::Builder.wont_be_nil
  end

  it 'must be a class we can call :new on' do
    Ngzip::Builder.new().wont_be_nil
  end

  it 'must respond to :build' do
    builder.respond_to?(:build).must_equal true
  end

  describe "with CRC-32 checksums disabled" do
    let(:options) { {:crc => false} }

    it 'must return a correct list for one file' do
      expected = "- 446 #{encode_file_path(lorem)} lorem.txt"
      builder.build(lorem, options).must_equal expected
    end
  end

  describe "with CRC-32 checksums enabled" do
    let(:options) { {:crc => true} }

    it 'must return a correct list for one file with a checksum' do
      expected = "8f92322f 446 #{encode_file_path(lorem)} lorem.txt"
      builder.build(lorem, options).must_equal expected
    end

    it 'must return a correct list for one binary file with a checksum' do
      expected = "b2f4655b 11550 #{encode_file_path(cargo)} Cargo.png"
      builder.build(cargo, options).must_equal expected
    end

    it 'must escape the path name' do
      expected = "8f92322f 446 #{encode_file_path(whitespaced)} A filename with whitespace.txt"
      builder.build(whitespaced, options).must_equal expected
    end

    it 'must return a correct list for all files in a directory' do
      expected = "8f92322f 446 #{encode_file_path(whitespaced)} A filename with whitespace.txt"
      expected << "\n8f92322f 446 #{encode_file_path(without_dot)} filename-without-a-dot"
      expected << "\n8f92322f 446 #{encode_file_path(ipsum)} ipsum.txt"
      expected << "\n8f92322f 446 #{encode_file_path(lorem)} lorem.txt"
      expected << "\n8f92322f 446 #{encode_file_path(my_file)} d/my_file.txt"
      builder.build(a, options).must_equal expected
    end

    it 'must allow to mix files and directories' do
      expected = "8f92322f 446 #{encode_file_path(whitespaced)} a/A filename with whitespace.txt"
      expected << "\n8f92322f 446 #{encode_file_path(without_dot)} a/filename-without-a-dot"
      expected << "\n8f92322f 446 #{encode_file_path(ipsum)} a/ipsum.txt"
      expected << "\n8f92322f 446 #{encode_file_path(lorem)} a/lorem.txt"
      expected << "\n8f92322f 446 #{encode_file_path(my_file)} a/d/my_file.txt"
      expected << "\nf7c0867d 1342 #{encode_file_path(sit)} sit.txt"
      builder.build([a, sit], options).must_equal expected
    end

    it 'must preserve directory names' do
      expected = [
        "8f92322f 446 #{encode_file_path(lorem)} a/lorem.txt",
        "8f92322f 446 #{encode_file_path(ipsum)} a/ipsum.txt",
        "b2f4655b 11550 #{encode_file_path(cargo)} b/Cargo.png"
      ].join("\n")
      builder.build([lorem, ipsum, cargo], options).must_equal expected
    end

    it 'must honor the CRC cache' do
      invalid_but_cached = "781aaabcc124"
      expected = "#{invalid_but_cached} 446 #{encode_file_path(lorem)} lorem.txt"
      builder.build(lorem, options.merge(:crc_cache => {lorem => invalid_but_cached})).must_equal expected
    end

    it 'must remove common directories by default' do
      pathes = builder.build([lorem, ipsum]).split("\n").map { |line| line.split.last }
      expected = ["lorem.txt", "ipsum.txt"]
      pathes.must_equal expected
    end

    it 'must keep common directories if :base_dir is provided' do
      options = {:base_dir => Pathname.new(lorem).parent.parent.to_s}
      pathes = builder.build([lorem, ipsum], options).split("\n").map { |line| line.split.last }
      expected = ["a/lorem.txt", "a/ipsum.txt"]
      pathes.must_equal expected
    end

    it 'must cope with a trailing / in the :base_dir' do
      options = {:base_dir => Pathname.new(lorem).parent.parent.to_s + '/'}
      pathes = builder.build([lorem, ipsum], options).split("\n").map { |line| line.split.last }
      expected = ["a/lorem.txt", "a/ipsum.txt"]
      pathes.must_equal expected
    end

    it 'must correctly encode filenames with a "+"' do
      options = {}
      name = File.join(Pathname.new(plused).parent.to_s, 'A filename with space and + in it.txt')
      expected = "8f92322f 446 #{encode_file_path(name)} A filename with space and + in it.txt"
      builder.build([plused], options).must_equal expected
    end

    it 'must correctly encode the "?" character' do
      name = File.join(Pathname.new(questions).parent.to_s, 'questions?/test.txt')
      expected = "f03102f5 13 #{encode_file_path(name)} test.txt"
      builder.build([File.join(questions, 'test.txt')]).must_equal expected
    end
  end
end
