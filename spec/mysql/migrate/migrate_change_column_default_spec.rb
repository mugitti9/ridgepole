# frozen_string_literal: true

describe 'Ridgepole::Client#diff -> migrate' do
  context 'when default:0 -> (empty)' do
    let(:actual_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", default: 0, null: false
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    let(:expected_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", limit: 4, null: true
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    let(:result_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no"
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(expected_dsl)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_ruby actual_dsl
      delta.migrate
      expect(subject.dump).to match_fuzzy result_dsl
    }
  end

  context 'when default:0 -> (employ with null:false)' do
    let(:actual_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", default: 0, null: false
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    let(:expected_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", null: false
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(expected_dsl)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_ruby actual_dsl
      delta.migrate
      expect(subject.dump).to match_ruby expected_dsl
    }
  end

  context 'when default:0 -> default:0' do
    let(:actual_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", default: 0, null: false
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(actual_dsl)
      expect(delta.differ?).to be_falsey
    }
  end

  context 'when default:0 -> default:0/null:true' do
    let(:actual_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", default: 0, null: false
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    let(:expected_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", limit: 4, default: 0, null: true
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    let(:result_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", default: 0
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(expected_dsl)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_ruby actual_dsl
      delta.migrate
      expect(subject.dump).to match_fuzzy result_dsl
    }
  end

  context 'when default:0/null:true -> default:nil/null:false' do
    let(:actual_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", default: 0
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    let(:expected_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", null: false
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    let(:result_dsl) do
      erbh(<<-ERB)
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", null: false
          t.date    "from_date", null: false
          t.float   "salary", null: false
          t.date    "to_date", null: false
        end
      ERB
    end

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      expect(Ridgepole::Logger.instance).to_not receive(:warn)

      delta = subject.diff(expected_dsl)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_ruby actual_dsl
      delta.migrate
      expect(subject.dump).to match_fuzzy result_dsl
    }
  end
end
