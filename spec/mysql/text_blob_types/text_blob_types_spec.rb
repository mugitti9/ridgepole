# frozen_string_literal: true

describe 'Ridgepole::Client (with new text/blob types)' do
  context 'when use new types' do
    subject { client }

    it do
      table_def = <<-RUBY
        create_table :foos, id: :unsigned_integer do |t|
          t.blob             :blob
          t.longblob         :long_blob
          t.longtext         :long_text
          t.mediumblob       :medium_blob
          t.mediumtext       :medium_text
          t.tinyblob         :tiny_blob
          t.tinytext         :tiny_text
          t.unsigned_bigint  :unsigned_bigint
          t.unsigned_decimal :unsigned_decimal
          t.unsigned_float   :unsigned_float
          t.unsigned_integer :unsigned_integer
        end
      RUBY
      delta = subject.diff(table_def)

      expect(delta.differ?).to be_truthy
      delta.migrate

      expect(subject.dump).to match_ruby erbh(<<-ERB)
        create_table "foos", id: { type: :integer, unsigned: true }, force: :cascade do |t|
          t.binary  "blob"
          t.binary  "long_blob", size: :long
          t.text    "long_text", size: :long
          t.binary  "medium_blob", size: :medium
          t.text    "medium_text", size: :medium
          t.binary  "tiny_blob", size: :tiny
          t.text    "tiny_text", size: :tiny
          t.bigint  "unsigned_bigint", unsigned: true
          t.decimal "unsigned_decimal", precision: 10, unsigned: true
          t.float   "unsigned_float", unsigned: true
          t.integer "unsigned_integer", unsigned: true
        end
      ERB

      expect(subject.diff(table_def).differ?).to be_falsey
    end
  end

  context 'when compare new types' do
    subject { client }

    before do
      subject.diff(<<-RUBY).migrate
        create_table "foos", force: :cascade do |t|
          t.binary "blob"
          t.binary "tiny_blob", size: :tiny
          t.binary "medium_blob", size: :medium
          t.binary "long_blob", size: :long
          t.text "tiny_text", size: :tiny
          t.text "medium_text", size: :medium
          t.text "long_text", size: :long
          t.decimal "unsigned_decimal", precision: 10, unsigned: true
          t.float "unsigned_float", unsigned: true
          t.bigint "unsigned_bigint", unsigned: true
          t.integer "unsigned_integer", unsigned: true
        end
      RUBY
    end

    it do
      delta = subject.diff(<<-RUBY)
        create_table "foos", force: :cascade do |t|
          t.binary "blob"
          t.binary "long_blob", size: :long
          t.text "long_text", size: :long
          t.binary "medium_blob", size: :medium
          t.text "medium_text", size: :medium
          t.binary "tiny_blob", size: :tiny
          t.text "tiny_text", size: :tiny
          t.bigint "unsigned_bigint", unsigned: true
          t.decimal "unsigned_decimal", precision: 10, unsigned: true
          t.float "unsigned_float", unsigned: true
          t.integer "unsigned_integer", unsigned: true
        end
      RUBY

      expect(delta.differ?).to be_falsey
    end
  end
end
