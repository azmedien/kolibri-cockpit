require 'rails_helper'
require 'carrierwave/test/matchers'

describe AssetsUploader do
  include CarrierWave::Test::Matchers

  let(:asset) { Asset.new }
  let(:uploader) { AssetsUploader.new(asset, :file) }

  after do
    # AssetsUploader.enable_processing = false
    # uploader.remove!
  end

  context 'png image content type' do
    let(:png) { File.open("#{Rails.root}/spec/fixtures/files/image.png") }

    before do
      AssetsUploader.enable_processing = true
      uploader.store!(png)
    end

    it "has the correct format" do
      expect(uploader).to be_format('png')
    end

    it "was recognized as square" do
      expect(uploader.is_square? png).to be_truthy
    end
  end

  context 'convert svg image' do
    let(:svg) { File.open("#{Rails.root}/spec/fixtures/files/scaleable.svg") }

    before do
      AssetsUploader.enable_processing = true
      uploader.store!(svg)
    end

    it "has the correct format" do
      expect(uploader).to be_format('png')
    end
  end

  context 'dont convert json document' do
    let(:json) { File.open("#{Rails.root}/spec/fixtures/files/runtime.json") }

    before do
      AssetsUploader.enable_processing = true
      uploader.store!(json)
    end

    it "has the correct format" do
      
    end
  end
end
