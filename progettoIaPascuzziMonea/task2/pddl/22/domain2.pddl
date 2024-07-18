(define (domain gestione_scarti)
  
  (:requirements :strips :typing :equality :adl)
  (:types
    location box content robot workstation carrier slot
  )
  ;un carrier può avere più slot, ogni slot indica una locazione disponibile per posizionare un box sul carrier. 
  ;Questa soluzione è un'alternativa all'uso dei fluents
  
  (:predicates
    (at_loc ?obj - (either robot workstation box content) ?loc - location)
    (is_empty ?box - box)
    (filled ?box - box ?cont - content)
    (at_ws ?obj - (either robot box content) ?ws - workstation)
    (carrying ?carrier - carrier ?box - box) ;<-modifica rispetto all'istanza 2.1
    ;non c'è più il predicato "free" perchè ora il robot ha il carrier per trasportare, quindi non avrà mai "le mani" occupate nel trasportare una scatola
    (connected ?loc1 ?loc2 - location)
    (is_warehouse ?loc - location)  ;individuiamo una ed una sola location come warehouse, perchè la warehouse ipotizziamo avere infinite risorse
    ;da qui in giù NUOVI PREDICATI rispetto all'istanza 2.1
    (joined ?robot - robot ?carrier - carrier)
    (handle ?car - carrier ?slot - slot)    ;un carrier possiede questo slot
    (free ?slot - slot) ;uno slot è libero e può essere riempito
  )

  ;il robot si muove da una location ad una adiacente (che non sia la warehouse)
  (:action move_to_loc
    :parameters (?r - robot ?from ?to - location ?car - carrier)
    :precondition (and (at_loc ?r ?from) (connected ?from ?to) (not (is_warehouse ?to)) (joined ?r ?car))
    :effect (and (not (at_loc ?r ?from)) (at_loc ?r ?to))
  )
  
  ;il robot si muove da una location ad una adiacente (che è la warehouse)
  ;abbiamo bisogno di queste due azioni molto simili, perchè nella warehouse ci possiamo andare solo con il carrier vuoto
  (:action move_to_warehouse
    :parameters (?r - robot ?from ?to - location ?car - carrier)
    :precondition (and 
      (at_loc ?r ?from) 
      (connected ?from ?to) 
      (is_warehouse ?to) 
      (joined ?r ?car) 
      (forall (?slot - slot) 
        (and 
          (handle ?car ?slot) 
          (free ?slot) 
        )
      )
    )
    :effect (and (not (at_loc ?r ?from)) (at_loc ?r ?to))
  )
  
  ;il robot entra in una workstation (facciamo risultare che il robot non è più dentro la location per evitare inconsistenze)
  (:action enter_ws
    :parameters (?r - robot ?loc - location ?ws - workstation ?car - carrier)
    :precondition (and (at_loc ?ws ?loc) (at_loc ?r ?loc) (not (at_ws ?r ?ws)) (joined ?r ?car))
    :effect (and (not (at_loc ?r ?loc)) (at_ws ?r ?ws))
  )
  
  ;il robot esce dalla workstation, ma comunque rimane nella location
  ;notiamo come ciò non crei inconsistenze perchè nella warehouse non ci sono workstation, dunque non rischiamo di far entrare nella warehouse un carrier "pieno"
  (:action exit_ws
    :parameters (?r - robot ?loc - location ?ws - workstation ?car - carrier)
    :precondition (and (at_loc ?ws ?loc) (not (at_loc ?r ?loc)) (at_ws ?r ?ws) (joined ?r ?car))
    :effect (and (at_loc ?r ?loc) (not (at_ws ?r ?ws)))
  )
  
  ;il robot posa la scatola che sta traportando nel carrier nella workstation in cui si trova
  (:action put_down_box_in_ws
    :parameters (?r - robot ?box - box ?ws - workstation ?car - carrier ?slot - slot)
    :precondition (and (at_ws ?r ?ws) (carrying ?car ?box) (joined ?r ?car) (handle ?car ?slot) (not (free ?slot)))
    :effect (and (not (carrying ?car ?box)) (at_ws ?box ?ws) (free ?slot))
  )
  
  ;il robot posa la scatola che sta traportando nel carrier nella location in cui si trova
  (:action put_down_box_in_loc
    :parameters (?r - robot ?box - box ?loc - location ?car - carrier ?slot - slot)
    :precondition (and (at_loc ?r ?loc) (carrying ?car ?box) (joined ?r ?car) (handle ?car ?slot) (not (free ?slot)))
    :effect (and (not (carrying ?car ?box)) (at_loc ?box ?loc) (free ?slot))
  )
  
  
  ;il robot carica una scatola dalla workstation in cui si trova (solo se vuoto)
  (:action load_boxes_from_ws
    :parameters (?r - robot ?box - box ?ws - workstation ?car - carrier ?slot - slot)
    :precondition (and (at_ws ?box ?ws) (at_ws ?r ?ws) (joined ?r ?car) (handle ?car ?slot) (free ?slot) )
    :effect (and (carrying ?car ?box) (not (free ?slot)) (not (at_ws ?box ?ws)))
  )
  
  ;il robot carica una scatola dalla location in cui si trova (solo se vuoto)
  (:action load_boxes_from_loc
    :parameters (?r - robot ?box - box ?loc - location ?car - carrier ?slot - slot)
    :precondition (and (at_loc ?box ?loc) (at_loc ?r ?loc) (joined ?r ?car) (handle ?car ?slot) (free ?slot))
    :effect (and (carrying ?car ?box) (not (free ?slot)) (not (at_loc ?box ?loc)))
  )
  
  ;se il carrier non sta caricando, e si trova in una workstation con un box pieno, il robot svuota il box, posizionando il contenuto nella workstation
  (:action empty_box_in_ws
    :parameters (?r - robot ?box - box ?ws - workstation ?con - content ?car - carrier)
    :precondition (and (at_ws ?r ?ws) (at_ws ?box ?ws) (filled ?box ?con) (joined ?r ?car))
    :effect (and (not (filled ?box ?con)) (is_empty ?box) (at_ws ?con ?ws))
  )

  ;se il carrier non sta caricando, e si trova in una workstation con un box vuoto, il robot riempie il box prendendo il contenuto dalla workstation
  (:action fill_box_in_ws
    :parameters (?r - robot ?box - box ?ws - workstation ?con - content ?car - carrier)
    :precondition (and (at_ws ?r ?ws) (at_ws ?box ?ws) (at_ws ?con ?ws) (is_empty ?box) (joined ?r ?car))
    :effect (and  (not (at_ws ?con ?ws)) (filled ?box ?con) (not (is_empty ?box)))
  )
  
  ;se il carrier non sta caricando, e si trova in una location con un box pieno, il robot svuota il box, posizionando il contenuto nella location
  (:action empty_box_in_loc
    :parameters (?r - robot ?box - box ?con - content ?loc - location ?car - carrier)
    :precondition (and (at_loc ?r ?loc) (at_loc ?box ?loc) (filled ?box ?con) (joined ?r ?car))
    :effect (and (not (filled ?box ?con)) (is_empty ?box) (at_loc ?con ?loc))
  )

  ;se il carrier non sta caricando, e si trova in una location con un box vuoto, il robot riempie il box prendendo il contenuto dalla location
  (:action fill_box_in_loc
    :parameters (?r - robot ?box - box ?con - content ?loc - location ?car - carrier)
    :precondition (and (not (is_warehouse ?loc)) (at_loc ?r ?loc) (at_loc ?box ?loc) (at_loc ?con ?loc) (is_empty ?box) (joined ?r ?car))
    :effect (and (not (at_loc ?con ?loc)) (filled ?box ?con) (not (is_empty ?box)))
  )
  
  ;se il carrier non sta caricando, e si trova nella warehouse con un box vuoto, il robot riempie il box e non consuma alcun oggetto
  (:action fill_box_in_warehouse
    :parameters (?r - robot ?box - box ?con - content ?loc - location ?car - carrier)
    :precondition (and (is_warehouse ?loc) (at_loc ?r ?loc) (at_loc ?box ?loc) (at_loc ?con ?loc) (is_empty ?box) (joined ?r ?car) )
    :effect (and (filled ?box ?con) (not (is_empty ?box)))
  )
)