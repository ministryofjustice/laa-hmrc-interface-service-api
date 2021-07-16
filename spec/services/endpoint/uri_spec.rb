require 'rails_helper'

RSpec.describe Endpoint::Uri do
  subject(:use_case) { described_class.new(href, use_case: 'use_case_one', from_date: from_date, to_date: to_date) }
  let(:href) { '/root/type/sub?matchID=123456' }
  let(:from_date) { '2021-01-01' }
  let(:to_date) { '2021-03-31' }
  it { is_expected.to be_a Endpoint::Uri }

  describe '.for_calling' do
    subject(:for_calling) { use_case.for_calling }

    context 'when the href just has a matchID' do
      it { is_expected.to eql '/root/type/sub?matchID=123456' }
    end

    context 'when the href has a matchID and requires dates' do
      let(:href) { '/root/type/sub?matchID=123456{&fromDate,toDate}' }

      it { is_expected.to eql '/root/type/sub?matchID=123456&fromDate=2021-01-01&toDate=2021-03-31' }
    end

    context 'when the href has a matchID and requires tax years' do
      let(:href) { '/root/type/sub?matchID=123456{&fromTaxYear,toTaxYear}' }

      it { is_expected.to eql '/root/type/sub?matchID=123456&fromTaxYear=2020-21&toTaxYear=2020-21' }

      context 'when the financial years differ' do
        let(:from_date) { '2021-02-01' }
        let(:to_date) { '2021-04-30' }

        it { is_expected.to eql '/root/type/sub?matchID=123456&fromTaxYear=2020-21&toTaxYear=2021-22' }
      end
    end
  end

  describe '.for_displaying' do
    subject(:for_displaying) { use_case.for_displaying }

    context 'when the href just has a matchID' do
      let(:href) { '/root/type?matchID=123456' }

      it { is_expected.to eql 'type' }
    end

    context 'when the href has a matchID and requires dates' do
      let(:href) { '/root/type/sub?matchID=123456{&fromDate,toDate}' }

      it { is_expected.to eql 'type/sub' }
    end

    context 'when the href has a matchID and requires tax years' do
      let(:href) { '/root/type/sub?matchID=123456{&fromTaxYear,toTaxYear}' }

      it { is_expected.to eql 'type/sub' }
    end

    context 'when the href contains matching' do
      let(:href) { '/root/matching/type/123456' }

      it { is_expected.to eql 'root/matching' }
    end
  end
end
