# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Actions::FixedFolder do
  around do |example|
    Dir.mktmpdir do |temp_dir|
      Dir.chdir temp_dir do
        FileUtils.copy_entry("#{RSPEC_ROOT}/support/#{fixture_path}", temp_dir)
        @temp_dir = temp_dir
        example.run
      end
    end
  end

  describe '#update!', :aggregate_failures do
    let(:final_dir) { File.join(@temp_dir, final_dir_artist, final_dir_album, "Jestes Cooler.mp3") }
    let(:final_dir2) { File.join(@temp_dir, final_dir_artist, final_dir_album, "Jestes Cooler2.mp3") }
    let(:final_dir_artist) { "Mroqły" }
    let(:final_dir_album) { "Qalbum" }

    context 'all good' do
      let(:fixture_path) { 'ok' }

      it 'leaves the filesystem as it was' do
        expect(File.file?(final_dir)).to be true

        described_class.new("Mroqły").update!

        expect(File.file?(final_dir)).to be true
      end
    end

    context 'changes required' do
      context 'changes accepted' do
        before do
          described_class.any_instance.stubs(gets: "y\n")
          Actions::MoveFolders.any_instance.stubs(gets: "y\n")
        end

        context "with feats" do
          let(:fixture_path) { 'with_feats' }

          before do
            Actions::CleanedFeatures.any_instance.stubs(gets: "y\n")
          end

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end

          it 'fixes the tags' do
            described_class.new("Mroqły").update!

            ID3Tag.read(File.open(final_dir)) do |tag|
              expect(tag.artist).to eq("Mroqły")
              expect(tag.title).to eq("Jesteś Cooler (feat. Dora)")
            end
          end
        end

        context "with feats, some already added" do
          let(:fixture_path) { 'with_feats_already_added' }

          before do
            Actions::CleanedFeatures.any_instance.stubs(gets: "y\n")
          end

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end

          it 'fixes the tags' do
            described_class.new("Mroqły").update!

            ID3Tag.read(File.open(final_dir)) do |tag|
              expect(tag.artist).to eq("Mroqły")
              expect(tag.title).to eq("Jesteś Cooler (feat. Dora & Zmora)")
            end
          end
        end

        context "with feats, with ampersand" do
          let(:fixture_path) { 'with_feats_ampersand' }

          before do
            Actions::CleanedFeatures.any_instance.stubs(gets: "y\n")
          end

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end

          it 'fixes the tags' do
            described_class.new("Mroqły").update!

            ID3Tag.read(File.open(final_dir)) do |tag|
              expect(tag.artist).to eq("Mroqły")
              expect(tag.title).to eq("Jesteś Cooler (feat. Dora & Zmora)")
            end
          end
        end

        context "with feats, with comma" do
          let(:fixture_path) { 'with_feats_comma' }

          before do
            Actions::CleanedFeatures.any_instance.stubs(gets: "y\n")
          end

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end

          it 'fixes the tags' do
            described_class.new("Mroqły").update!

            ID3Tag.read(File.open(final_dir)) do |tag|
              expect(tag.artist).to eq("Mroqły")
              expect(tag.title).to eq("Jesteś Cooler (feat. Dora & Zmora)")
            end
          end
        end

        context "with feats, with comma" do
          let(:fixture_path) { 'with_feats_comma' }

          before do
            Actions::CleanedFeatures.any_instance.stubs(gets: "y\n")
          end

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end

          it 'fixes the tags' do
            described_class.new("Mroqły").update!

            ID3Tag.read(File.open(final_dir)) do |tag|
              expect(tag.artist).to eq("Mroqły")
              expect(tag.title).to eq("Jesteś Cooler (feat. Dora & Zmora)")
            end
          end
        end

        context "with double artist" do
          let(:fixture_path) { 'artist_is_a_duo' }

          before do
            Actions::CleanedFeatures.any_instance.stubs(gets: "y\n")
          end

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end

          it 'fixes the tags' do
            described_class.new("Mroqły").update!

            ID3Tag.read(File.open(final_dir)) do |tag|
              expect(tag.artist).to eq("Mroqły & Dora")
              expect(tag.title).to eq("Jesteś Cooler")
            end

            ID3Tag.read(File.open(final_dir2)) do |tag|
              expect(tag.artist).to eq("Mroqły & Dora")
              expect(tag.title).to eq("Jesteś Cooler Remix (feat. Zmora & Delikat)")
            end
          end
        end

        context "all tracks have the same feature" do
          let(:fixture_path) { 'artist_is_a_duo_from_features' }

          before do
            Actions::CleanedFeatures.any_instance.stubs(gets: "y\n")
          end

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end

          it 'fixes the tags' do
            described_class.new("Mroqły").update!

            ID3Tag.read(File.open(final_dir)) do |tag|
              expect(tag.artist).to eq("Mroqły & Dora")
              expect(tag.title).to eq("Jesteś Cooler")
            end

            ID3Tag.read(File.open(final_dir2)) do |tag|
              expect(tag.artist).to eq("Mroqły & Dora")
              expect(tag.title).to eq("Jesteś Cooler Remix (feat. Delikat)")
            end
          end
        end
      end
    end
  end
end
