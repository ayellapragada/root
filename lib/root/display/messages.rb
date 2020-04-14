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
        v_char_sel: {
          prompt: 'Pick a Vagabond to be your Character',
          history: 'Picked the %s Character'
        },
        v_forest_sel: {
          prompt: 'Pick a Forest to start in',
          history: 'Placed Warrior in forest %s'
        },
        c_initial_keep: {
          prompt: 'Pick where to place the Keep',
          history: ''
        },
        c_initial_sawmill: {
          prompt: 'Pick where to place first Sawmill',
          history: ''
        },
        c_initial_workshop: {
          prompt: 'Pick where to place first Workshop',
          history: ''
        },
        c_initial_recruiter: {
          prompt: 'Pick where to place first Recruiter',
          history: ''
        },
        c_overwork: {
          prompt: 'Pick a clearing to get an extra wood in',
          history: 'Overworked in clearing %s'
        },
        c_recruit: {
          prompt: '',
          history: 'Recruited in clearing(s) %s'
        },
        c_wood_removal: {
          prompt: 'Pick clearings to remove wood from',
          history: ''
        },
        f_item_selet: {
          prompt: 'Pick an item to craft',
          history: 'Crafted %s for %s victory point(s)'
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
          history: 'Did %s damage and recieved %s damage from %s'
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
          prompt: 'Pick an action to take',
          history: ''
        },
        f_draw_cards: {
          prompt: '',
          history: 'Drew %s card(s)'
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
          history: 'Added %s Suit to %s in Decre'
        },
        b_comeback_roost: {
          prompt: 'Pick where to place your new first Roost with 3 Warriors',
          history: 'Setup comeback roost in clearing %s'
        },
        b_recruit_clearing: {
          prompt: 'Pick which clearing to recruit in',
          history: 'Recruited in clearing %s'
        },
        b_turmoil: {
          prompt: '',
          history: 'Went into turmoil'
        }
      }.freeze
    end
  end
end
