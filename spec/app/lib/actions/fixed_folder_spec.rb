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
          Cli::Approval.stubs(gets: "y\n")
        end

        context "loose folder" do
          let(:fixture_path) { 'loose_folder' }

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end

          it "doesn't leave any leftover folders" do
            described_class.new("Mroqły").update!

            expect(Dir.glob(File.join(@temp_dir, '*'))).to eq [File.join(@temp_dir, 'Mroqły')]
          end
        end

        context "wrong album" do
          let(:fixture_path) { 'wrong_album' }

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end
        end

        context "wrong artist" do
          let(:fixture_path) { 'wrong_artist' }

          it 'fixes the filesystem' do
            described_class.new("xxx").update!

            expect(File.file?(final_dir)).to be true
          end
        end

        context "wrong ascii" do
          let(:fixture_path) { 'wrong_ascii' }

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end
        end

        context "wrong artist, but folder for the right artist already exists" do
          let(:fixture_path) { 'wrong_artist' }

          before do
            Dir.mkdir(File.join(@temp_dir, "Mroqły"))
          end

          it 'fixes the filesystem' do
            described_class.new("xxx").update!

            expect(File.file?(final_dir)).to be true
          end
        end

        context "artist with slash in the name" do
          let(:fixture_path) { 'artist_with_slash' }
          let(:final_dir_artist) { "Mroqł_y" }

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end

          it "doesn't change the tags" do
            described_class.new("Mroqły").update!

            ID3Tag.read(File.open(final_dir)) do |tag|
              expect(tag.artist).to eq("Mroqł/y")
            end
          end
        end

        context "album with slash in the name" do
          let(:fixture_path) { 'album_with_slash' }
          let(:final_dir_album) { "Qalbu_m" }

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end

          it "doesn't change the tags" do
            described_class.new("Mroqły").update!

            ID3Tag.read(File.open(final_dir)) do |tag|
              expect(tag.album).to eq("Qalbu/m")
            end
          end
        end

        context "artist is two dots" do
          let(:fixture_path) { 'album_is_dots' }
          let(:final_dir_album) { "_" }

          it 'fixes the filesystem' do
            described_class.new("Mroqły").update!

            expect(File.file?(final_dir)).to be true
          end

          it "doesn't change the tags" do
            described_class.new("Mroqły").update!

            ID3Tag.read(File.open(final_dir)) do |tag|
              expect(tag.album).to eq("..")
            end
          end
        end
      end

      context 'changes rejected' do
        let(:fixture_path) { 'loose_folder' }

        before do
          Cli::Approval.stubs(gets: "n\n")
        end

        it 'leaves the filesystem as it was' do
          org_dir = File.join(@temp_dir, "Mroqły", "Jesteś Cooler.mp3")

          expect(File.file?(org_dir)).to be true
          described_class.new("Mroqły").update!
          expect(File.file?(org_dir)).to be true
          expect(File.file?(final_dir)).to be false
        end
      end

      context 'ascii changes rejected' do
        let(:fixture_path) { 'wrong_ascii' }

        before do
          Cli::Approval.stubs(gets: "n\n")
        end

        it 'leaves the filesystem as it was' do
          org_dir = File.join(@temp_dir, "Mroqły", "Qalbum", "Jesteś Cooler.mp3")

          expect(File.file?(org_dir)).to be true
          described_class.new("Mroqły").update!
          expect(File.file?(org_dir)).to be true
          expect(File.file?(final_dir)).to be false
        end
      end
    end
  end
end
