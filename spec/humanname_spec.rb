# encoding: UTF-8

require 'spec_helper'

describe HumanName do
  describe 'parse' do
    it 'parses simple name' do
      n = HumanName.parse("Jane Doe")
      expect(n.given_name).to eq('Jane')
      expect(n.surname).to eq('Doe')
      expect(n.middle_names).to be_nil
      expect(n.suffix).to be_nil
      expect(n.display_full).to eq('Jane Doe')
      expect(n.display_first_last).to eq('Jane Doe')
      expect(n.display_initial_surname).to eq('J. Doe')
      expect(n.goes_by_middle_name).to be false
      expect(n.length).to eq(8)
    end

    it 'parses complex name' do
      n = HumanName.parse("JOHN ALLEN Q DE LA MACDONALD JR")
      expect(n.given_name).to eq('John')
      expect(n.surname).to eq('de la MacDonald')
      expect(n.middle_names).to eq('Allen')
      expect(n.suffix).to eq('Jr.')
      expect(n.display_full).to eq('John Allen Q. de la MacDonald, Jr.')
      expect(n.display_first_last).to eq('John de la MacDonald')
      expect(n.display_initial_surname).to eq('J. de la MacDonald')
      expect(n.length).to eq('John Allen Q. de la MacDonald, Jr.'.length)
    end

    it 'returns nil on failure' do
      expect(HumanName.parse 'nope').to be_nil
    end

    it 'handles non-UTF8 encoding' do
      input = "Björn O'Malley-Muñoz".encode("ISO-8859-1")
      n = HumanName.parse(input)
      expect(n.given_name).to eq("Björn") # normalized nfkd
      expect(n.surname).to eq("O'Malley-Muñoz") # normalized nfkd
    end
  end

  describe '==' do
    it 'is true for identical names' do
      expect(HumanName.parse "Jane Doe").to eq(HumanName.parse "Jane Doe")
    end

    it 'is true for consistent but non-identical names' do
      expect(HumanName.parse "Jane Doe").to eq(HumanName.parse "J. Doe")
    end

    it 'is false for inconsistent names' do
      expect(HumanName.parse "Jane Doe").not_to eq(HumanName.parse "John Doe")
    end
  end

  describe 'hash' do
    it 'is identical for identical names' do
      expect(HumanName.parse("Jane Doe").hash).to eq(HumanName.parse("Jane Doe").hash)
    end

    it 'is identical for consistent names' do
      expect(HumanName.parse("Jane Doe").hash).to eq(HumanName.parse("J. Doe").hash)
    end

    it 'is different for names with different surnames' do
      expect(HumanName.parse("Jane Doe").hash).not_to eq(HumanName.parse("J. Dee").hash)
    end
  end

  describe 'matches_slug_or_localpart' do
    it 'is true given match' do
      expect(HumanName.parse("Jane Doe").matches_slug_or_localpart('janexdoe')).to be_truthy
    end

    it 'is false given non-match' do
      expect(HumanName.parse("Jane Doe").matches_slug_or_localpart('johnxdoe')).to be_falsey
    end
  end

  it 'implements as_json' do
    n = HumanName.parse("JOHN ALLEN Q DE LA MACDONALD JR")
    expect(n.as_json).to eq({
      given_name: 'John',
      surname: 'de la MacDonald',
      middle_names: 'Allen',
      first_initial: 'J',
      middle_initials: 'AQ',
      suffix: 'Jr.',
    })
  end

  it 'does not leak memory' do
    def rss
      GC.start
      `ps -o rss= -p #{Process.pid}`.chomp.to_i
    end

    before = rss

    100000.times do
      n = HumanName.parse("Reallyverylongfirstname Reallyverylonglastname")
      HumanName::NAME_PARTS.each { |part| n.send(part) }
    end

    expect(rss).to be < 2 * before
  end
end
