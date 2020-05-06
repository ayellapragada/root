# frozen_string_literal: true

RSpec.describe Root::Factions::Racoons::Relationships do
  describe '#initialize' do
    it 'sets markers for all other factions to neutral' do
      relationships = build_relationships
      expect(relationships.count).to eq(3)
      expect(relationships.all_neutral?).to be true
    end
  end

  describe '#aid_once' do
    it 'aids faction once bumping to next status if at threshold' do
      relationships = build_relationships
      expect(relationships.vp_to_gain).to eq(0)

      relationships.aid_once(:cats)

      expect(relationships[:cats][:num_aided]).to eq(0)
      expect(relationships[:cats][:status]).to eq(1)
      expect(relationships.vp_to_gain).to eq(1)

      relationships.aid_once(:cats)

      expect(relationships[:cats][:num_aided]).to eq(1)
      expect(relationships[:cats][:status]).to eq(1)
      expect(relationships.vp_to_gain).to eq(0)

      relationships.aid_once(:cats)

      expect(relationships[:cats][:num_aided]).to eq(0)
      expect(relationships[:cats][:status]).to eq(2)
      expect(relationships.vp_to_gain).to eq(2)
    end

    context 'when at maximum relationship status' do
      it 'does not increase relationship status more' do
        relationships = build_relationships
        6.times { relationships.aid_once(:cats) }

        expect(relationships[:cats][:num_aided]).to eq(0)
        expect(relationships[:cats][:status]).to eq(3)

        4.times { relationships.aid_once(:cats) }
        expect(relationships[:cats][:num_aided]).to eq(4)
        expect(relationships[:cats][:status]).to eq(3)
      end
    end

    context 'when hostile' do
      it 'does not improve status' do
        relationships = build_relationships
        relationships.make_hostile(:cats)
        relationships.aid_once(:cats)

        expect(relationships[:cats][:num_aided]).to eq(1)
        expect(relationships[:cats][:status]).to eq(9)
      end
    end
  end

  describe '#reset_turn_counters' do
    it 'resets the number of times aided in a turn' do
      relationships = build_relationships
      relationships.aid_once(:cats)
      relationships.aid_once(:cats)

      expect(relationships[:cats][:num_aided]).to eq(1)
      expect(relationships[:cats][:status]).to eq(1)

      relationships.reset_turn_counters

      expect(relationships[:cats][:num_aided]).to eq(0)
      expect(relationships[:cats][:status]).to eq(1)
    end
  end

  def build_relationships
    list = Root::Players::List.default_player_list
    p1 = list.fetch_player(:racoon)
    others = list.except_player(p1)
    Root::Factions::Racoons::Relationships.new(others)
  end
end
