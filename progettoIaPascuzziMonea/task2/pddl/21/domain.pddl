(define (domain gestione_scarti)
  (:requirements :strips :typing :equality :adl :universal-preconditions)
  (:types 
    location box content robot workstation
  )
  (:predicates 
    (at_loc ?obj - (either robot workstation box content) ?loc - location)
    (is_empty ?box - box)
    (filled ?box - box ?cont - content)
    (at_ws ?obj - (either robot box content) ?ws - workstation)
    (carrying ?robot - robot ?box - box)
    (free ?robot - robot) ;se il robot sta traportando una scatola allora non deve essere "free", ma per fare tutte le altre mansioni (escluso lo spostamento) deve esserlo
    (connected ?loc1 ?loc2 - location)
    (is_warehouse ?loc - location)  ;individuiamo una ed una sola location come warehouse, perchè la warehouse ipotizziamo avere infinite risorse
  )
  
  ;il robot si muove da una location ad una adiacente
  (:action move_to_loc
    :parameters (?r - robot ?from ?to - location)
    :precondition (and (at_loc ?r ?from) (connected ?from ?to))
    :effect (and (not (at_loc ?r ?from)) (at_loc ?r ?to))
  )
  
  ;il robot entra in una workstation (facciamo risultare che il robot non è più dentro la location per evitare inconsistenze)
  (:action enter_ws
    :parameters (?r - robot ?loc - location ?ws - workstation)
    :precondition (and (at_loc ?ws ?loc) (at_loc ?r ?loc) (not (at_ws ?r ?ws)) )
    :effect (and (not (at_loc ?r ?loc)) (at_ws ?r ?ws))
  )
  
  ;il robot esce dalla workstation, ma comunque rimane nella location
  (:action exit_ws
    :parameters (?r - robot ?loc - location ?ws - workstation)
    :precondition (and (at_loc ?ws ?loc) (not (at_loc ?r ?loc)) (at_ws ?r ?ws))
    :effect (and (at_loc ?r ?loc) (not (at_ws ?r ?ws)))
  )
  
  ;il robot posa la scatola che sta traportando nella workstation in cui si trova
  (:action put_down_box_in_ws
    :parameters (?r - robot ?box - box ?ws - workstation)
    :precondition (and (at_ws ?r ?ws) (carrying ?r ?box))
    :effect (and (not (carrying ?r ?box)) (free ?r) (at_ws ?box ?ws))
  )
  
  ;il robot posa la scatola che sta traportando nella location in cui si trova
  (:action put_down_box_in_loc
    :parameters (?r - robot ?box - box ?loc - location)
    :precondition (and (at_loc ?r ?loc) (carrying ?r ?box))
    :effect (and (not (carrying ?r ?box)) (free ?r) (at_loc ?box ?loc))
  )
  
  ;il robot solleva la scatola che sta traportando dalla workstation in cui si trova
  (:action put_up_box_from_ws
    :parameters (?r - robot ?box - box ?ws - workstation)
    :precondition (and (at_ws ?box ?ws) (at_ws ?r ?ws) (free ?r))
    :effect (and (carrying ?r ?box) (not (free ?r)) (not (at_ws ?box ?ws)))
  )
  
  ;il robot solleva la scatola che sta traportando dalla location in cui si trova
  (:action put_up_box_from_loc
    :parameters (?r - robot ?box - box ?loc - location)
    :precondition (and (at_loc ?box ?loc) (at_loc ?r ?loc) (free ?r))
    :effect (and (carrying ?r ?box) (not (free ?r)) (not (at_loc ?box ?loc)))
  )
  
  ;se il robot non è occupato, e si trova in una workstation con un box pieno, lo svuota, posizionando il contenuto nella workstation
  (:action empty_box_in_ws
    :parameters (?r - robot ?box - box ?ws - workstation ?con - content)
    :precondition (and (free ?r) (at_ws ?r ?ws) (at_ws ?box ?ws) (filled ?box ?con))
    :effect (and (not (filled ?box ?con)) (is_empty ?box) (at_ws ?con ?ws))
  )

  ;se il robot non è occupato, e si trova in una workstation con un box vuoto, lo riempie prendendo il contenuto dalla workstation
  (:action fill_box_in_ws
    :parameters (?r - robot ?box - box ?ws - workstation ?con - content)
    :precondition (and (free ?r) (at_ws ?r ?ws) (at_ws ?box ?ws) (at_ws ?con ?ws) (is_empty ?box))
    :effect (and  (not (at_ws ?con ?ws)) (filled ?box ?con) (not (is_empty ?box)))
  )
  
  ;se il robot non è occupato, e si trova in una location con un box pieno, lo svuota, posizionando il contenuto nella location
  (:action empty_box_in_loc
    :parameters (?r - robot ?box - box ?con - content ?loc - location)
    :precondition (and (free ?r) (at_loc ?r ?loc) (at_loc ?box ?loc) (filled ?box ?con))
    :effect (and (not (filled ?box ?con)) (is_empty ?box) (at_loc ?con ?loc))
  )

  ;se il robot non è occupato, e si trova in una location con un box vuoto, lo riempie prendendo il contenuto dalla location
  (:action fill_box_in_loc
    :parameters (?r - robot ?box - box ?con - content ?loc - location)
    :precondition (and (not (is_warehouse ?loc)) (free ?r) (at_loc ?r ?loc) (at_loc ?box ?loc) (at_loc ?con ?loc) (is_empty ?box))
    :effect (and (not (at_loc ?con ?loc)) (filled ?box ?con) (not (is_empty ?box)))
  )
  
  ;se il robot non è occupato, e si trova nella warehouse con un box vuoto, lo riempie e non consuma alcun oggetto
  (:action fill_box_in_warehouse
    :parameters (?r - robot ?box - box ?con - content ?loc - location)
    :precondition (and (is_warehouse ?loc) (free ?r) (at_loc ?r ?loc) (at_loc ?box ?loc) (at_loc ?con ?loc) (is_empty ?box))
    :effect (and (filled ?box ?con) (not (is_empty ?box)))
  )
)