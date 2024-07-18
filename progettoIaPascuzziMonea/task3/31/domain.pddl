(define (domain gestione_scarti)
  (:requirements :strips :typing :durative-actions :equality :numeric-fluents)
  (:types
    location box content robot workstation carrier
  )
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
  )
  (:functions
    (capacity ?carrier - carrier)
    (load ?carrier - carrier)
  )
  
  ;il robot si muove da una location ad una adiacente (che non sia la warehouse)
  (:durative-action move_to_loc
    :parameters (?r - robot ?from ?to - location ?car - carrier)
    :duration (= ?duration 3)
    :condition (and 
      (at start(at_loc ?r ?from))
      (over all(connected ?from ?to)) 
      (over all(not (is_warehouse ?to))) 
      (over all(joined ?r ?car)))
    :effect (and 
      (at start(not (at_loc ?r ?from)))
      (at end(at_loc ?r ?to))
    )
  )
  
  ;il robot si muove da una location ad una adiacente (che è la warehouse)
  ;abbiamo bisogno di queste due azioni molto simili, perchè nella warehouse ci possiamo andare solo con il carrier vuoto
  (:durative-action move_to_warehouse
    :parameters (?r - robot ?from ?to - location ?car - carrier)
    :duration (= ?duration 3)
    :condition (and 
      (at start(at_loc ?r ?from)) 
      (over all(connected ?from ?to)) 
      (over all(is_warehouse ?to)) 
      (over all(joined ?r ?car)) 
    )
    :effect (and 
      (at start(not (at_loc ?r ?from))) 
      (at end(at_loc ?r ?to)))
  )
  
  ;il robot entra in una workstation (facciamo risultare che il robot non è più dentro la location per evitare inconsistenze)
  (:durative-action enter_ws
    :parameters (?r - robot ?loc - location ?ws - workstation ?car - carrier)
    :duration (= ?duration 0)
    :condition (and 
      (over all(at_loc ?ws ?loc)) 
      (at start(at_loc ?r ?loc)) 
      (over all(joined ?r ?car)))
    :effect (and 
      (at start(not (at_loc ?r ?loc))) 
      (at end(at_ws ?r ?ws)))
  )
  
  ;il robot esce dalla workstation, ma comunque rimane nella location
  ;notiamo come ciò non crei inconsistenze perchè nella warehouse non ci sono workstation, dunque non rischiamo di far entrare nella warehouse un carrier "pieno"
  (:durative-action exit_ws
    :parameters (?r - robot ?loc - location ?ws - workstation ?car - carrier)
    :duration (= ?duration 0)
    :condition (and 
      (over all(at_loc ?ws ?loc)) 
      (at start(at_ws ?r ?ws)) 
      (over all(joined ?r ?car))
    )
    :effect (and 
      (at end(at_loc ?r ?loc)) 
      (at start(not (at_ws ?r ?ws)))
    )
  )
  
  ;il robot posa la scatola che sta traportando nel carrier nella workstation in cui si trova
  (:durative-action put_down_box_in_ws
    :parameters (?r - robot ?box - box ?ws - workstation ?car - carrier)
    :duration (= ?duration 2)
    :condition (and 
      (over all (at_ws ?r ?ws)) 
      (at start (carrying ?car ?box)) 
      (over all (joined ?r ?car))
    )
    :effect (and 
      (at start (not (carrying ?car ?box))) 
      (at end (at_ws ?box ?ws)) 
      (at end (decrease (load ?car) 1)))
  )
  
  ;il robot posa la scatola che sta traportando nel carrier nella location in cui si trova
  (:durative-action put_down_box_in_loc
    :parameters (?r - robot ?box - box ?loc - location ?car - carrier)
    :duration (= ?duration 2)
    :condition (and 
      (over all (at_loc ?r ?loc)) 
      (at start (carrying ?car ?box)) 
      (over all (joined ?r ?car)))
    :effect (and 
      (at start (not (carrying ?car ?box))) 
      (at end (at_loc ?box ?loc)) 
      (at end (decrease (load ?car) 1)))
  )
  
  ;il robot carica una scatola dalla workstation in cui si trova (solo se vuoto)
  (:durative-action load_boxes_from_ws
    :parameters (?r - robot ?box - box ?ws - workstation ?car - carrier)
    :duration (= ?duration 2)
    :condition (and 
      (at start (at_ws ?box ?ws)) 
      (over all (at_ws ?r ?ws)) 
      (over all (joined ?r ?car)) 
      (over all (< (load ?car) (capacity ?car))))
    :effect (and 
      (at end (carrying ?car ?box)) 
      (at end (increase (load ?car) 1)) 
      (at start (not (at_ws ?box ?ws)))
    )
  )
  
  ;il robot carica una scatola dalla location in cui si trova (solo se vuoto)
  (:durative-action load_boxes_from_loc
    :parameters (?r - robot ?box - box ?loc - location ?car - carrier)
    :duration (= ?duration 2)
    :condition (and 
      (at start (at_loc ?box ?loc)) 
      (over all (at_loc ?r ?loc)) 
      (over all (joined ?r ?car)) 
      (over all (< (load ?car) (capacity ?car))))
    :effect (and 
      (at end (carrying ?car ?box)) 
      (at end (increase (load ?car) 1)) 
      (at start (not (at_loc ?box ?loc)))
    )
  )
  
  ;se il carrier non sta caricando, e si trova in una workstation con un box pieno, il robot svuota il box, posizionando il contenuto nella workstation
  (:durative-action empty_box_in_ws
    :parameters (?r - robot ?box - box ?ws - workstation ?con - content ?car - carrier)
    :duration (= ?duration 3.5)
    :condition (and 
      (over all (at_ws ?r ?ws)) 
      (at start (at_ws ?box ?ws)) 
      (at start (filled ?box ?con)) 
      (over all (joined ?r ?car))
    )
    :effect (and 
      (at start (not (filled ?box ?con))) 
      (at end (is_empty ?box)) 
      (at end (at_ws ?con ?ws))
      (at end (at_ws ?box ?ws))
    )
  )

  ;se il carrier non sta caricando, e si trova in una workstation con un box vuoto, il robot riempie il box prendendo il contenuto dalla workstation
  (:durative-action fill_box_in_ws
    :parameters (?r - robot ?box - box ?ws - workstation ?con - content ?car - carrier)
    :duration (= ?duration 3.5)
    :condition (and 
      (over all (at_ws ?r ?ws)) 
      (over all (at_ws ?box ?ws)) 
      (at start (at_ws ?con ?ws)) 
      (at start (is_empty ?box)) 
      (over all (joined ?r ?car))
    )
    :effect (and 
      (at start (not (at_ws ?con ?ws))) 
      (at end (filled ?box ?con)) 
      (at start (not (is_empty ?box))))
  )
  
  ;se il carrier non sta caricando, e si trova in una location con un box pieno, il robot svuota il box, posizionando il contenuto nella location
  (:durative-action empty_box_in_loc
    :parameters (?r - robot ?box - box ?con - content ?loc - location ?car - carrier)
    :duration (= ?duration 3.5)
    :condition (and 
      (over all (at_loc ?r ?loc)) 
      (at start (at_loc ?box ?loc)) 
      (at start (filled ?box ?con)) 
      (over all (joined ?r ?car))
    )
    :effect (and 
      (at start (not (filled ?box ?con))) 
      (at end (is_empty ?box)) 
      (at end (at_loc ?con ?loc))
    )
  )

  ;se il carrier non sta caricando, e si trova in una location con un box vuoto, il robot riempie il box prendendo il contenuto dalla location
  (:durative-action fill_box_in_loc
    :parameters (?r - robot ?box - box ?con - content ?loc - location ?car - carrier)
    :duration (= ?duration 3.5)
    :condition (and 
      (over all (not (is_warehouse ?loc))) 
      (over all (at_loc ?r ?loc)) 
      (at start (at_loc ?box ?loc)) 
      (at start (at_loc ?con ?loc)) 
      (at start (is_empty ?box)) 
      (over all (joined ?r ?car))
    )
    :effect (and 
      (at start (not (at_loc ?con ?loc))) 
      (at end (filled ?box ?con)) 
      (at start (not (is_empty ?box))))
  )
  
  ;se il carrier non sta caricando, e si trova nella warehouse con un box vuoto, il robot riempie il box e non consuma alcun oggetto
  (:durative-action fill_box_in_warehouse
    :parameters (?r - robot ?box - box ?con - content ?loc - location ?car - carrier)
    :duration (= ?duration 3.5)
    :condition (and 
      (over all (is_warehouse ?loc)) 
      (over all (at_loc ?r ?loc)) 
      (over all (at_loc ?box ?loc)) 
      (at start (at_loc ?con ?loc)) 
      (at start (is_empty ?box)) 
      (over all (joined ?r ?car))
    )
    :effect (and 
      (at end (filled ?box ?con)) 
      (at start (not (is_empty ?box)))
    )
  )
)