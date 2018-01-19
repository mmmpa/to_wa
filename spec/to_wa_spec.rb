require './spec/spec_helper'

RSpec.describe ToWa do
  before(:all) { DatabaseCleaner.start }
  before(:all) { DatabaseCleaner.clean! }

  before :all do
    TestRecord.create(id: 1, a: 'a', b: 'b', c: 'c', x: 1, y: 2, z: 3)
    TestRecord.create(id: 2, a: 'abc', b: 'bcd', c: 'cde', x: 11, y: 12, z: 13)
    TestRecord.create(id: 3, a: 'a', b: 'b', c: 'c', x: 2, y: 5, z: 8)
    TestRecord.create(id: 4, a: 'a', b: 'b', c: 'c', x: 3, y: 6, z: 9)
    TestRecord.create(id: 5, a: 'a', b: 'b', c: 'c', x: 4, y: 7, z: 10)
  end

  it do
    expect(ToWa::Core).to receive(:to_wa).once
    TestRecord.to_wa({})
  end

  it do
    expect(ToWa::Core).to receive(:to_wa).once
    TestRecord.select(:id).to_wa({})
  end

  describe 'test' do
    subject(:o) { TestRecord.to_wa(ex).ids }
    subject(:size) { TestRecord.to_wa(ex).count }
    subject { TestRecord.to_wa(ex) }

    context do
      let(:ex) { { '=' => ['a', 'abc'] } }
      it { expect(o).to eq([2]) }
      it { expect(size).to eq(1) }
    end

    context do
      let(:ex) { { 'between' => ['x', [1, 3]] } }
      it { expect(o).to eq([1, 3, 4]) }
      it { expect(size).to eq(3) }
      it { expect(subject.where(id: 1).ids).to eq([1]) }
      it { expect(subject.order(id: :desc).ids).to eq([4, 3, 1]) }
    end

    context do
      let(:ex) { { 'and' => [{ '=' => ['a', 'a'] }, { '!=' => ['b', 'bcd'] }] } }
      it { expect(o).to eq([1, 3, 4, 5]) }
      it { expect(size).to eq(4) }
    end

    context do
      let(:ex) { { 'or' => [{ '=' => ['b', 'bcd'] }, { '>=' => ['z', '10'] }] } }
      it { expect(o).to eq([2, 5]) }
      it { expect(size).to eq(2) }
    end
  end

  describe 'operators' do
    it do
      ToWa::Core::COMPARISON.keys.each do |op|
        case op
        when 'between', 'in'
          expect { TestRecord.to_wa({ op => ['a', ['aaa', 'bbb']] }).to_sql }.not_to raise_error
        else
          expect { TestRecord.to_wa({ op => ['a', 'aaa'] }).to_sql }.not_to raise_error
        end
      end
    end

    it do
      ToWa::Core::LOGICAL.keys.each do |op|
        expect { TestRecord.to_wa({ op => [{ '=' => ['a', 'aaa'] }, { '=' => ['a', 'aaa'] }] }).to_sql }.not_to raise_error
      end
    end
  end

  describe 'build sql' do
    subject { TestRecord.to_wa(ex).to_sql }

    context do
      let(:ex) { { '=' => ['a', 'aaa'] } }
      it { is_expected.to include("`test_records`.`a` = 'aaa'") }
    end

    context do
      let(:ex) { { 'like' => ['a', 'aaa'] } }
      it { is_expected.to include("`test_records`.`a` LIKE '%aaa%'") }
    end

    context do
      let(:ex) { { 'like' => ['a', '100%'] } }
      it { is_expected.to include("`test_records`.`a` LIKE '%100\\\\%%'") }
    end

    context do
      let(:ex) { { 'between' => ['x', [0, 3]] } }
      it { is_expected.to include('`test_records`.`x` BETWEEN 0 AND 3') }
    end

    context do
      let(:ex) { { 'in' => ['a', ['aaa', 'bbb']] } }
      it { is_expected.to include("`test_records`.`a` IN ('aaa', 'bbb')") }
    end

    context do
      let(:ex) {
        {
          'not' => [
            { '=' => ['a', 'aaa'] },
          ],
        }
      }
      it { is_expected.to include("NOT (`test_records`.`a` = 'aaa')") }
    end

    context do
      let(:ex) {
        {
          'not' => [
            {
              'and' => [
                { '=' => ['a', 'aaa'] },
                { '=' => ['b', 'bbb'] },
              ],
            },
          ],
        }
      }
      it { is_expected.to include("NOT ((`test_records`.`a` = 'aaa' AND `test_records`.`b` = 'bbb'))") }
    end

    context do
      let(:ex) {
        {
          'and' => [
            { '=' => ['a', 'aaa'] },
            { '=' => ['b', 'bbb'] },
          ],
        }
      }
      it { is_expected.to include("(`test_records`.`a` = 'aaa' AND `test_records`.`b` = 'bbb')") }
    end

    context do
      let(:ex) {
        {
          'and' => [
            { '=' => ['a', 'aaa'] },
            { '=' => ['b', 'bbb'] },
            {
              'or' => [
                { '=' => ['x', 1] },
                { '=' => ['y', 2] },
              ],
            },
          ],
        }
      }
      it { is_expected.to include("(`test_records`.`a` = 'aaa' AND `test_records`.`b` = 'bbb' AND (`test_records`.`x` = 1 OR `test_records`.`y` = 2))") }
    end

    context 'comparison with comparisons' do
      let(:ex) {
        {
          'and' => [
            {
              'or' => [
                { '=' => ['a', 'aaa'] },
                { '=' => ['b', 'bbb'] },
              ],
            },
            {
              'or' => [
                { '=' => ['x', 1] },
                { '=' => ['y', 2] },
              ],
            },
          ],
        }
      }
      it { is_expected.to include("(`test_records`.`a` = 'aaa' OR `test_records`.`b` = 'bbb') AND (`test_records`.`x` = 1 OR `test_records`.`y` = 2)") }
    end

    context 'comparison with one value' do
      let(:ex) {
        {
          'and' => [
            {
              'or' => [
                { '=' => ['x', 1] },
                { '=' => ['y', 2] },
              ],
            },
          ],
        }
      }
      it { is_expected.to include('(`test_records`.`x` = 1 OR `test_records`.`y` = 2)') }
    end
  end
end
