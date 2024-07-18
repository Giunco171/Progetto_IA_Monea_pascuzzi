(define (problem easy_istance)
  (:domain manufactoring_service)

  (:objects
    loc1 loc2 warehouse - location
    box1 box2 - box
    bolts valves - content
    robot - robot
    ws1 ws2 - workstation
  )

  (:init
  
    (at_loc robot warehouse)
    
    (at_loc box1 warehouse)
    (at_loc box2 warehouse)
    
    (at_loc bolts warehouse)
    (at_loc valves warehouse)
    
    (is_empty box1)
    (is_empty box2)
    
    (free robot)
    
    (connected loc1 loc2)
    (connected loc2 warehouse)
    (connected warehouse loc1)
    
    (at_loc ws1 loc1)
    (at_loc ws2 loc2)
    
    (is_warehouse warehouse)
  )

  (:goal
    (and
      (at_ws box1 ws1)
      (at_ws box2 ws2)
      (filled box1 bolts)
      (filled box2 valves)
    )
  )
)