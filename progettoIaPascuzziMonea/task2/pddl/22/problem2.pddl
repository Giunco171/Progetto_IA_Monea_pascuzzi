(define (problem warehouse_problem)
  (:domain gestione_scarti)

  (:objects
    robot - robot
    carrier - carrier
    warehouse location1 location2 - location
    workstation1 workstation2 workstation3 - workstation
    box1 box2 box3 - box
    bolt screw - content
    slot1 slot2 slot3 - slot    ;tre slot vogliono dire che il carrier ha capacità pari a 3
  )

  (:init
    ; Il robot si trova nella warehouse
    (at_loc robot warehouse)
    
    ;colleghiamo il carrier al robot
    (joined robot carrier)
    
    ;identifichiamo la warehouse
    (is_warehouse warehouse)

    ; I box sono collocati nella warehouse
    (at_loc box1 warehouse)
    (at_loc box2 warehouse)
    (at_loc box3 warehouse)

    ; I contenuti da mettere nei box sono nella warehouse
    (at_loc bolt warehouse)
    (at_loc screw warehouse)
    
    ;le scatole sono vuote
    (is_empty box1)
    (is_empty box2)
    (is_empty box3)
    
    ;posizioniamo le workstation
    (at_loc workstation1 location1)
    (at_loc workstation2 location2)
    (at_loc workstation3 location2)
    
    ;connessioni
    (connected warehouse location1)
    (connected location1 location2)
    (connected location1 warehouse)
    (connected location2 location1)
    
    ;impostiamo la capacità del carrier
    (handle carrier slot1)
    (handle carrier slot2) 
    (handle carrier slot3) 
    (free slot1)
    (free slot2)
    (free slot3)
  )

  (:goal
    (and
      ; Almeno una workstation che necessita di un bullone
      (at_ws bolt workstation2)

      ; Almeno una workstation che non necessita di nulla
      (not (at_ws bolt workstation1))
      (not (at_ws screw workstation1))

      ; Almeno una workstation che necessita di bulloni e viti
      (at_ws bolt workstation3)
      (at_ws screw workstation3)

    )
  )
)