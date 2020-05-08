# frozen_string_literal: true

module Root
  module Display
    # All messages, basically a more complicated en.yml tbh
    class Messages
      LIST = {
        test_option: {
          prompt: 'Test Option',
          history: 'Test Option'
        },
        c_initial_keep: {
          prompt: 'Pick where to place the Keep',
          history: ''
        },
        c_initial_building: {
          prompt: 'Pick where to place first %s',
          history: ''
        },
        c_overwork: {
          prompt: 'Pick a clearing to get a wood in',
          history: 'Overworked in clearing %s'
        },
        c_recruit: {
          prompt: 'Pick clearing to recruit in',
          history: 'Recruited in clearing(s) %s'
        },
        c_wood_removal: {
          prompt: 'Pick clearings to remove wood from',
          history: ''
        },
        c_field_hospital: {
          prompt: 'Use Field Hospital for 1 card of %s suit for %s meeple(s)',
          history: 'Used Field Hospital in %s to recover %s meeples'
        },
        f_item_select: {
          prompt: 'Pick an item to craft',
          history: 'Crafted %s for %s VP(s)'
        },
        f_discard_card: {
          prompt: 'Pick a card to discard',
          history: 'Discarded a %s card'
        },
        f_build_options: {
          prompt: 'Pick a clearing to build in',
          history: 'Built a %s in clearing %s'
        },
        f_who_to_battle: {
          prompt: 'Pick a faction to battle against',
          history: 'Did %s and recieved %s damage from %s in clearing %s'
        },
        f_battle_options: {
          prompt: 'Pick a clearing to battle in',
          history: ''
        },
        f_pick_building: {
          prompt: 'Pick a type of building to make',
          history: ''
        },
        f_move_from_options: {
          prompt: 'Pick a clearing to move from',
          history: ''
        },
        f_move_to_options: {
          prompt: 'Pick a clearing to move to',
          history: ''
        },
        f_move_number: {
          prompt: 'Pick a number of meeples to move',
          history: 'Moved %s warrior(s) from clearing %s to clearing %s'
        },
        f_pick_action: {
          prompt: 'Pick an action to take %s',
          history: ''
        },
        f_draw_cards: {
          prompt: '',
          history: 'Drew %s card(s)'
        },
        f_dice_roll: {
          prompt: '',
          history: 'Rolled a %s and %s in clearing %s'
        },
        f_remove_piece: {
          prompt: 'Pick which piece to remove in clearing %s',
          history: ''
        },
        f_recruit_clearing: {
          prompt: 'Pick which clearing to recruit in',
          history: 'Recruited in clearing %s'
        },
        f_game_over: {
          prompt: '',
          history: 'Game over! Winner is %s with type of victory %s'
        },
        b_new_leader: {
          prompt: 'Pick the next leader',
          history: 'Picked %s as new Leader'
        },
        b_first_roost: {
          prompt: 'Pick where to place the first Roost with 6 Warriors',
          history: 'Setup initial Roost in clearing %s'
        },
        b_card_for_decree: {
          prompt: 'Pick card to place into decree',
          history: ''
        },
        b_area_in_decree: {
          prompt: 'Pick a area in decree to place card',
          history: 'Added %s Suit to %s in Decree'
        },
        b_comeback_roost: {
          prompt: 'Pick where to place your new first Roost with 3 Warriors',
          history: 'Setup comeback roost in clearing %s'
        },
        b_turmoil: {
          prompt: '',
          history: 'Went into turmoil'
        },
        m_outrage_card: {
          prompt: 'Pick card to give to supporters',
          history: ''
        },
        m_supporter_to_use: {
          prompt: 'Pick which supporter to use',
          history: ''
        },
        m_revolt: {
          prompt: 'Pick clearing to revolt in',
          history: ''
        },
        m_spread_sympathy: {
          prompt: 'Pick clearing to spread sympathy to',
          history: ''
        },
        m_mobilize: {
          prompt: 'Pick a card to mobilize into supporters',
          history: ''
        },
        m_train: {
          prompt: 'Pick a card to use to train an officer',
          history: ''
        },
        m_organize_clearing: {
          prompt: 'Pick a clearing to revolt in',
          history: ''
        },
        r_char_sel: {
          prompt: 'Pick a Racoon to be your Character',
          history: 'Picked the %s Character'
        },
        r_forest_sel: {
          prompt: 'Pick a Forest to start in',
          history: 'Placed Warrior in forest %s'
        },
        r_item_refresh: {
          prompt: 'Pick an item to refresh. %s refresh(es) left',
          history: 'Repaired the %s'
        },
        r_item_damage: {
          prompt: 'Pick an item to damage',
          history: 'Damaged the %s'
        },
        r_item_exhaust: {
          prompt: 'Pick an item to exhaust',
          history: 'Exhausted the %s'
        },
        r_item_discard: {
          prompt: 'Pick an item to discard',
          history: ''
        },
        r_explore: {
          prompt: '',
          history: 'Explored a ruin in clearing %s and gained (a) %s'
        },
        r_item_repair: {
          prompt: 'Pick an item to repair. %s repair(s) left',
          history: 'Repaired the %s'
        },
        r_quest: {
          prompt: 'Pick a quest to accomplish',
          history: 'Completed a %s quest with %s'
        },
        r_quest_reward: {
          prompt: 'Pick a quest reward, draw 2 cards or get %s VP(s)',
          history: 'Reward: %s'
        },
        r_aid_faction: {
          prompt: 'Pick a faction to aid',
          history: 'Aided the %s'
        },
        r_card_to_give: {
          prompt: 'Pick a card to give the other faction',
          history: ''
        },
        r_item_to_get: {
          prompt: 'Pick an item to get from the other faction',
          history: ''
        },
        r_allied_move: {
          prompt: 'Pick an allied faction to move with you',
          history: ''
        },
        r_allied_battle: {
          prompt: 'Pick an allied faction to aid you in battle',
          history: ''
        },
        r_c_steal: {
          prompt: 'Pick a faction steal a card from',
          history: 'Stole a card from the %s'
        },
        r_c_day_labor: {
          prompt: 'Pick a card from the discard pile to take',
          history: 'Retrieved a card from the discard pile'
        },
        r_c_hideout: {
          prompt: '',
          history: 'Repaired 3 items and ended turn.'
        }
      }.freeze
    end
  end
end
