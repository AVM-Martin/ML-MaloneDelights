(defglobal
    ?*counter* = 0
    ?*return-value* = -1

    ?*FOODTYPE* = (create$ "Italian" "Chinese" "Mexican")
    ?*FOODPRICEMIN* = (create$ 15.00  1.50  5.00)
    ?*FOODPRICEMAX* = (create$ 80.00 20.00 25.00)
)

; ==================================================================================================
; template

(deftemplate food (slot name) (slot rating) (slot foodtype) (slot price))

(deftemplate foodplan
    (slot name) (slot duration)
    (slot foodname) (slot qty) (slot price)
)

(deffacts food-list
    (food (name "Tomato Salsa") (rating 5.0) (foodtype "Mexican") (price 5.00))
    (food (name "Margherita Pizza") (rating 4.7) (foodtype "Italian") (price 20.00))
    (food (name "Szechwan Chili Chicken") (rating 4.0) (foodtype "Chinese") (price 2.00))
    (food (name "Stir Fried Tofu with Rice") (rating 4.9) (foodtype "Chinese") (price 4.00))
    (food (name "Pork Fried Rice") (rating 4.2) (foodtype "Chinese") (price 7.50))
    (food (name "Pasta Carbonara") (rating 5.0) (foodtype "Italian") (price 15.00))
    (food (name "Chicken Quesadillas") (rating 4.5) (foodtype "Mexican") (price 8.00))
)

(deffacts foodplan-list
    (foodplan
        (name "Rice Tofu Package") (duration 365)
        (foodname "Stir Fried Tofu with Rice") (qty 100) (price 16685.71)
    )
    (foodplan
        (name "Salsa Package") (duration 120)
        (foodname "Tomato Salsa") (qty 500) (price 34285.71)
    )
    (foodplan
        (name "Pizza Package") (duration 300)
        (foodname "Margherita Pizza") (qty 200) (price 137142.85)
    )
)

; ==================================================================================================
; facts-accessor template + rule + query + helper function

(deftemplate fact-query (slot name) (slot data (default 0)))


(defrule display-food
    (fact-query (name "display-food"))
    (food (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price))
    =>
    (++ ?*counter*)
    (bind ?*return-value* ?*counter*)
    (format t
        "| %2d | %-28s | %-6.2f | %s | $ %10.2f |"
        ?*counter* ?name ?rating ?foodtype ?price
    )
    (printout t crlf)
)

(defrule display-foodplan
    (fact-query (name "display-foodplan"))
    (foodplan (name ?name) (duration ?duration) (foodname ?foodname) (qty ?qty) (price ?price))
    =>
    (++ ?*counter*)
    (bind ?*return-value* ?*counter*)
    (format t
        "| %2d | %-20s | %-15d | %-28s | %8d | $ %10.2f |"
        ?*counter* ?name ?duration ?foodname ?qty ?price
    )
    (printout t crlf)
)


(defrule index-food
    (fact-query (name "index-food") (data ?data))
    ?index <- (food)
    =>
    (++ ?*counter*)
    (if (eq ?*counter* ?data) then
        (bind ?*return-value* ?index)
    )
)

(defrule index-foodplan
    (fact-query (name "index-foodplan") (data ?data))
    ?index <- (foodplan)
    =>
    (++ ?*counter*)
    (if (eq ?*counter* ?data) then
        (bind ?*return-value* ?index)
    )
)

(defrule price-food
    (fact-query (name "price-food") (data ?data))
    (food (name ?data) (price ?price))
    =>
    (bind ?*return-value* ?price)
)


(deffunction fact-query(?name ?data)
    (bind ?id (assert (fact-query (name ?name) (data ?data))))
    (run)
    (bind ?result ?*return-value*)
    (retract ?id)

    (bind ?*counter* 0)
    (bind ?*return-value* -1)

    (return ?result)
)

(deffunction display(?name) (return (fact-query (str-cat "display-" ?name) 0)))
(deffunction index(?name ?data) (return (fact-query (str-cat "index-" ?name) ?data)))
(deffunction price-food(?data) (return (fact-query "price-food" ?data)))

; ==================================================================================================
; helper functions

(deffunction read-int(?text)
    (bind ?result "")

    (while (eq (str-compare ?result "") 0)
        (printout t ?text)
        (try
            (bind ?result (integer (readline)))
        catch
            (printout t "Input must be an integer" crlf)
            (bind ?result "")
        )
    )

    (return ?result)
)

(deffunction read-float(?text)
    (bind ?result "")

    (while (eq (str-compare ?result "") 0)
        (printout t ?text)
        (try
            (bind ?result (float (readline)))
        catch
            (printout t "Input must be a float" crlf)
            (bind ?result "")
        )
    )

    (return ?result)
)

(deffunction read-string(?text)
    (bind ?result "")

    (printout t ?text)
    (bind ?result (readline))

    (return ?result)
)

(deffunction cls()
    (for (bind ?i 1) (< ?i 50) (++ ?i)
        (printout t crlf)
    )
)

(deffunction pause-back()
    (printout t crlf crlf "Press ENTER to back to main menu...")
    (readline)
)

; ==================================================================================================
; CRUD functions

(deffunction create-food()
    (bind ?name "")
    (while (or (< (str-length ?name) 5) (< 28 (str-length ?name)))
        (bind ?name (read-string "Input new Foods name [5 - 28 Characters]: "))
    )

    (bind ?rating -1.0)
    (while (or (< ?rating 0.0) (< 5.0 ?rating))
        (bind ?rating (read-float "Input new Foods rating [0.0 - 5.0 stars]: "))
    )

    (bind ?foodtype "")
    (while (not (member$ ?foodtype ?*FOODTYPE*))
        (bind ?foodtype (read-string "Input new Foods type [Italian | Chinese | Mexican]: "))
    )

    (bind ?price -1.0)
    (bind ?price-min (nth$ (member$ ?foodtype ?*FOODTYPE*) ?*FOODPRICEMIN*))
    (bind ?price-max (nth$ (member$ ?foodtype ?*FOODTYPE*) ?*FOODPRICEMAX*))
    (while (or (< ?price ?price-min) (< ?price-max ?price))
        (bind ?price (read-float (str-cat "Food price [" ?price-min " - " ?price-max "]: $")))
    )

    (assert (food (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price)))
    (printout t ?name " Successfully added!!" crlf)
)

(deffunction create-foodplan()
    (bind ?name "")
    (while (or (eq (str-compare ?name "") 0) (<= 20 (str-length ?name)))
        (bind ?name (read-string "Input new plans name [Must end with 'Plan' | < 20 Characters]: "))

        (if (or
                (neq (str-index "Plan" ?name) (- (str-length ?name) 3))
                (eq (str-compare ?name "Plan") 0)
            ) then
            (bind ?name "")
        )
    )

    (bind ?duration 0)
    (while (or (< ?duration 10) (< 3650 ?duration))
        (bind ?duration (read-int "Input new plans duration [10 days to 10 years | Insert in days]: "))
    )

    (view-food)
    (bind ?foodname "")
    (bind ?foodprice -1)
    (while (< ?foodprice 0)
        (bind ?foodname (read-string "Input a Food for this plan: "))
        (bind ?foodprice (price-food ?foodname))
    )

    (bind ?qty 0)
    (while (not (> ?qty 10))
        (bind ?qty (read-int "Input Food quantity distributed per week [> 10 portion]: "))
    )

    (bind ?price (* (* (* ?foodprice 0.8) (/ ?duration 7)) ?qty))
    (printout t "This plans total price is $" ?price crlf)

    (assert (foodplan
        (name ?name) (duration ?duration)
        (foodname ?foodname) (qty ?qty) (price ?price)
    ))
    (printout t ?name " Successfully added!!" crlf)
)


(deffunction view-food()
    (printout t "FOOD LIST" crlf)
    (printout t "=======================================================================" crlf)
    (printout t "| No | Name                         | Rating | Type    | Price        |" crlf)
    (printout t "=======================================================================" crlf)
    (bind ?result (display "food"))
    (printout t "=======================================================================" crlf)
    (return ?result)
)

(deffunction view-foodplan()
    (printout t "PLAN LIST" crlf)
    (printout t "========================================================================================================" crlf)
    (printout t "| No | Plan Name            | Duration (days) | Food Name                    | Quantity | Price        |" crlf)
    (printout t "========================================================================================================" crlf)
    (bind ?result (display "foodplan"))
    (printout t "========================================================================================================" crlf)
    (return ?result)
)


(deffunction update-food()
    (bind ?size (view-food))
    (bind ?index -1)
    (while (or (< ?index 1) (< ?size ?index))
        (bind ?index (read-int "Item number to be updated: "))
    )

    (bind ?name "")
    (while (or (< (str-length ?name) 5) (< 28 (str-length ?name)))
        (bind ?name (read-string "Input new Foods name [5 - 28 Characters]: "))
    )

    (bind ?rating -1.0)
    (while (or (< ?rating 0.0) (< 5.0 ?rating))
        (bind ?rating (read-float "Input new Foods rating [0.0 - 5.0 stars]: "))
    )

    (bind ?foodtype "")
    (while (not (member$ ?foodtype ?*FOODTYPE*))
        (bind ?foodtype (read-string "Input new Foods type [Italian | Chinese | Mexican]: "))
    )

    (bind ?price -1.0)
    (bind ?price-min (nth$ (member$ ?foodtype ?*FOODTYPE*) ?*FOODPRICEMIN*))
    (bind ?price-max (nth$ (member$ ?foodtype ?*FOODTYPE*) ?*FOODPRICEMAX*))
    (while (or (< ?price ?price-min) (< ?price-max ?price))
        (bind ?price (read-float (str-cat "Food price [" ?price-min " - " ?price-max "]: $")))
    )

    (modify
        (index "food" ?index)
        (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price)
    )
    (printout t "Update Successful!" crlf)
)

(deffunction update-foodplan()
    (bind ?size (view-foodplan))
    (bind ?index -1)
    (while (or (< ?index 1) (< ?size ?index))
        (bind ?index (read-int "Item number to be updated: "))
    )

    (bind ?name "")
    (while (or (eq (str-compare ?name "") 0) (<= 20 (str-length ?name)))
        (bind ?name (read-string "Input new plans name [Must end with 'Plan' | < 20 Characters]: "))

        (if (or
                (neq (str-index "Plan" ?name) (- (str-length ?name) 3))
                (eq (str-compare ?name "Plan") 0)
            ) then
            (bind ?name "")
        )
    )

    (bind ?duration 0)
    (while (or (< ?duration 10) (< 3650 ?duration))
        (bind ?duration (read-int "Input new plans duration [10 days to 10 years | Insert in days]: "))
    )

    (view-food)
    (bind ?foodname "")
    (bind ?foodprice -1)
    (while (< ?foodprice 0)
        (bind ?foodname (read-string "Input a Food for this plan: "))
        (bind ?foodprice (price-food ?foodname))
    )

    (bind ?qty 0)
    (while (not (> ?qty 10))
        (bind ?qty (read-int "Input Food quantity distributed per week [> 10 portion]: "))
    )

    (bind ?price (* (* (* ?foodprice 0.8) (/ ?duration 7)) ?qty))
    (printout t "This plans total price is $" ?price crlf)

    (modify
        (index "foodplan" ?index)
        (name ?name) (duration ?duration) (foodname ?foodname) (qty ?qty) (price ?price)
    )
    (printout t "Update Successful!" crlf)
)


(deffunction delete-food()
    (bind ?size (view-food))
    (bind ?index -1)
    (while (or (< ?index 1) (< ?size ?index))
        (bind ?index (read-int "Item number to be deleted: "))
    )

    (retract (index "food" ?index))
    (printout t "Delete Successful!" crlf)
)

(deffunction delete-foodplan()
    (bind ?size (view-foodplan))
    (bind ?index -1)
    (while (or (< ?index 1) (< ?size ?index))
        (bind ?index (read-int "Item number to be deleted: "))
    )

    (retract (index "foodplan" ?index))
    (printout t "Delete Successful!" crlf)
)

; ==================================================================================================
; recommendation stuffs

(deftemplate suggest-question
    (slot id)
    (slot description (default ""))
    (slot question)
    (multislot possible-answer (default "Yes" "No"))
)

(deftemplate suggest-ask (slot id))
(deftemplate suggest-answer (slot id) (slot answer))
(deftemplate suggest-food (slot name) (slot rating) (slot foodtype) (slot price))
(deftemplate suggest-foodplan
    (slot name) (slot duration)
    (slot foodname) (slot qty) (slot price)
)


(defrule suggest-ask-question
    (suggest-question
        (id ?id) (description ?description)
        (question ?question)
        (possible-answer $?possible-answer)
    )
    ?index <- (suggest-ask (id ?id))
    (not (suggest-answer (id ?id)))
    =>
    (if (neq (str-compare ?description "") 0) then
        (printout t ?description crlf)
    )

    (bind ?answer "")
    (while (not (member$ ?answer $?possible-answer))
        (bind ?answer (read-string ?question))
    )
    (assert (suggest-answer (id ?id) (answer ?answer)))
)


(defquery suggest-food
    (declare (variables))
    (suggest-food (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price))
)

(defquery suggest-foodplan
    (declare (variables))
    (suggest-foodplan
        (name ?name) (duration ?duration)
        (foodname ?foodname) (qty ?qty) (price ?price)
    )
)

; ==================================================================================================
; recommendation helper

(deftemplate suggest-query (slot name))


(defrule suggest-reset-ask
    (suggest-query (name "reset-ask"))
    ?index <- (suggest-ask)
    =>
    (retract ?index)
)

(defrule suggest-reset-answer
    (suggest-query (name "reset-answer"))
    ?index <- (suggest-answer)
    =>
    (retract ?index)
)

(defrule suggest-reset-food
    (suggest-query (name "reset-food"))
    ?index <- (suggest-food)
    =>
    (retract ?index)
)

(defrule suggest-reset-foodplan
    (suggest-query (name "reset-foodplan"))
    ?index <- (suggest-foodplan)
    =>
    (retract ?index)
)

(defrule suggest-foodplan-init
    (suggest-query (name "init-foodplan"))
    (foodplan
        (name ?name) (duration ?duration)
        (foodname ?foodname) (qty ?qty) (price ?price)
    )
    (food (name ?foodname))
    =>
    (assert (suggest-foodplan
        (name ?name) (duration ?duration)
        (foodname ?foodname) (qty ?qty) (price ?price)
    ))
)


(deffunction suggest-reset()
    (bind $?queries (create$ "reset-ask" "reset-answer" "reset-food" "reset-foodplan"))
    (foreach ?query $?queries
        (bind ?index (assert (suggest-query (name ?query))))
        (run)
        (retract ?index)
    )
)

; ==================================================================================================
; list of questions + knowledge rules (FOOD)

(deffacts suggest-food-question
    (suggest-question
        (id 100) (description "Tell us the quality of food you need..")
        (question "High or Moderate? ")
        (possible-answer "High" "Moderate")
    )
    (suggest-question
        (id 101) (question "Do you need foods for official purpose? [Yes | No]: ")
    )
    (suggest-question
        (id 102) (question "Are you open to other options of food besides normal Italian? [Yes | No]: ")
    )
    (suggest-question
        (id 103) (description "Tell us your budget scale..")
        (question "Your budget scale [Low | High | Unlimited]: ")
        (possible-answer "Low" "High" "Unlimited")
    )
)


(defrule suggest-100-high
    (suggest-answer (id 100) (answer "High"))
    =>
    (assert (suggest-ask (id 101)))
)

(defrule suggest-100-moderate
    (suggest-answer (id 100) (answer "Moderate"))
    =>
    (assert (suggest-ask (id 103)))
)

(defrule suggest-101-yes
    (suggest-answer (id 101) (answer "Yes"))
    =>
    (assert (suggest-ask (id 102)))
)

(defrule suggest-101-no
    (suggest-answer (id 101) (answer "No"))
    =>
    (assert (suggest-ask (id 103)))
)

(defrule suggest-food-solution-1
    (suggest-answer (id 100) (answer "High"))
    (suggest-answer (id 101) (answer "Yes"))
    (suggest-answer (id 102) (answer "Yes"))
    (food (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price))
    =>
    (assert (suggest-food
        (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price)
    ))
)

(defrule suggest-food-solution-2
    (suggest-answer (id 100) (answer "High"))
    (suggest-answer (id 101) (answer "Yes"))
    (suggest-answer (id 102) (answer "No"))
    (food (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price))
    (test (eq (str-compare ?foodtype "Italian") 0))
    =>
    (assert (suggest-food
        (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price)
    ))
)

(defrule suggest-food-solution-3
    (suggest-answer (id 100) (answer "High"))
    (suggest-answer (id 101) (answer "No"))
    (suggest-answer (id 103) (answer "Low"))
    (food (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price))
    (test (< ?price 4))
    =>
    (assert (suggest-food
        (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price)
    ))
)

(defrule suggest-food-solution-4
    (suggest-answer (id 100) (answer "High"))
    (suggest-answer (id 101) (answer "No"))
    (suggest-answer (id 103) (answer "High"))
    (food (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price))
    (test (< ?price 100))
    =>
    (assert (suggest-food
        (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price)
    ))
)

(defrule suggest-food-solution-5
    (suggest-answer (id 100) (answer "High"))
    (suggest-answer (id 101) (answer "No"))
    (suggest-answer (id 103) (answer "Unlimited"))
    (food (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price))
    =>
    (assert (suggest-food
        (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price)
    ))
)

(defrule suggest-food-solution-6
    (suggest-answer (id 100) (answer "Moderate"))
    (suggest-answer (id 103) (answer "Low"))
    (food (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price))
    (test (< ?price 3))
    =>
    (assert (suggest-food
        (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price)
    ))
)

(defrule suggest-food-solution-7
    (suggest-answer (id 100) (answer "Moderate"))
    (suggest-answer (id 103) (answer "High"))
    (food (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price))
    (test (< ?price 15))
    =>
    (assert (suggest-food
        (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price)
    ))
)

(defrule suggest-food-solution-7
    (suggest-answer (id 100) (answer "Moderate"))
    (suggest-answer (id 103) (answer "Unlimited"))
    (food (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price))
    =>
    (assert (suggest-food
        (name ?name) (rating ?rating) (foodtype ?foodtype) (price ?price)
    ))
)

; ==================================================================================================
; list of questions + knowledge rules (FOODPLAN)

(deffacts suggest-foodplan-question
    (suggest-question
        (id 200) (description "Choose the quality of Food..")
        (question "Your Foods quality [High | Moderate]: ")
        (possible-answer "High" "Moderate")
    )
    (suggest-question
        (id 201) (description "Tell us your budget scale..")
        (question "Your budget scale [Small | Medium | Large | Unlimited]: ")
        (possible-answer "Small" "Medium" "Large" "Unlimited")
    )
    (suggest-question
        (id 202) (description "Tell us how big are your needs..")
        (question "Your scale of need [Personal Purposes | Small Scale | Large Scale]: ")
        (possible-answer "Personal Purposes" "Small Scale" "Large Scale")

    )
)


(defrule suggest-foodplan-solution-200-high
    (suggest-answer (id 200) (answer "High"))
    ?index <- (suggest-foodplan (foodname ?foodname))
    (food (name ?foodname) (foodtype ?foodtype))
    (test (not
        (eq (str-compare ?foodtype "Italian") 0)
    ))
    =>
    (retract ?index)
)

(defrule suggest-foodplan-solution-200-moderate
    (suggest-answer (id 200) (answer "Moderate"))
    ?index <- (suggest-foodplan (foodname ?foodname))
    (food (name ?foodname) (foodtype ?foodtype))
    (test (not (or
        (eq (str-compare ?foodtype "Mexican") 0)
        (eq (str-compare ?foodtype "Chinese") 0)
    )))
    =>
    (retract ?index)
)


(defrule suggest-foodplan-solution-201-small
    (suggest-answer (id 201) (answer "Small"))
    ?index <- (suggest-foodplan (price ?price))
    (test (not (< ?price 10000)))
    =>
    (retract ?index)
)

(defrule suggest-foodplan-solution-201-medium
    (suggest-answer (id 201) (answer "Medium"))
    ?index <- (suggest-foodplan (price ?price))
    (test (not (< ?price 50000)))
    =>
    (retract ?index)
)

(defrule suggest-foodplan-solution-201-large
    (suggest-answer (id 201) (answer "Large"))
    ?index <- (suggest-foodplan
        (name ?name) (duration ?duration)
        (foodname ?foodname) (qty ?qty) (price ?price)
    )
    (test (not (< ?price 100000)))
    =>
    (retract ?index)
)


(defrule suggest-foodplan-solution-202-personal
    (suggest-answer (id 202) (answer "Personal Purposes"))
    ?index <- (suggest-foodplan (qty ?qty))
    (test (not (< ?qty 50)))
    =>
    (retract ?index)
)

(defrule suggest-foodplan-solution-202-small
    (suggest-answer (id 202) (answer "Small Scale"))
    ?index <- (suggest-foodplan (qty ?qty))
    (test (not (< ?qty 1000)))
    =>
    (retract ?index)
)

(defrule suggest-foodplan-solution-202-large
    (suggest-answer (id 202) (answer "Large Scale"))
    ?index <- (suggest-foodplan (qty ?qty))
    (test (not (< ?qty 5000)))
    =>
    (retract ?index)
)

; ==================================================================================================
; recommendation functions

(deffunction suggest-food()
    (assert (suggest-ask (id 100)))
    (run)

    (new EmptyTemplate)
)

(deffunction suggest-foodplan()
    (bind ?index (assert (suggest-query (name "init-foodplan"))))
    (run)
    (retract ?index)
    (assert (suggest-ask (id 200)))
    (assert (suggest-ask (id 201)))
    (assert (suggest-ask (id 202)))
    (run)

    (new EmptyTemplate)
)

; ==================================================================================================
; menu functions

(deffunction get-menu()
    (printout t "=================================" crlf)
    (printout t "|        MALONE DELIGHTS        |" crlf)
    (printout t "=================================" crlf)
    (printout t "| 1. View Foods                 |" crlf)
    (printout t "| 2. Add Food                   |" crlf)
    (printout t "| 3. Update Food                |" crlf)
    (printout t "| 4. Delete Food                |" crlf)
    (printout t "| 5. Food Planning Consultation |" crlf)
    (printout t "| 6. Exit                       |" crlf)
    (printout t "=================================" crlf)

    (bind ?result -1)
    (while (or (< ?result 1) (< 6 ?result))
        (bind ?result (read-int "Choose [1..6]: "))
    )
    (printout t crlf crlf)
    (return ?result)
)

(deffunction get-category()
    (printout t "Categories to Choose" crlf)
    (printout t "--------------------" crlf)
    (printout t "1. Food" crlf)
    (printout t "2. Food Plans" crlf)

    (bind ?result -1)
    (while (or (< ?result 0) (< 2 ?result))
        (bind ?result (read-int "Choose [1..2 | 0 to go back to main menu]: "))
    )
    (printout t crlf crlf)
    (return ?result)
)

(deffunction menu-1-view()
    (bind ?category (get-category))
    (if (eq ?category 1) then
        (view-food)
        (pause-back)
    elif (eq ?category 2) then
        (view-foodplan)
        (pause-back)
    )
)

(deffunction menu-2-add()
    (bind ?category (get-category))
    (if (eq ?category 1) then
        (create-food)
        (pause-back)
    elif (eq ?category 2) then
        (create-foodplan)
        (pause-back)
    )
)

(deffunction menu-3-update()
    (bind ?category (get-category))
    (if (eq ?category 1) then
        (update-food)
        (pause-back)
    elif (eq ?category 2) then
        (update-foodplan)
        (pause-back)
    )
)

(deffunction menu-4-delete()
    (bind ?category (get-category))
    (if (eq ?category 1) then
        (delete-food)
        (pause-back)
    elif (eq ?category 2) then
        (delete-foodplan)
        (pause-back)
    )
)

(deffunction menu-5-recommendation()
    (suggest-reset)

    (bind ?category (get-category))
    (if (eq ?category 1) then
        (suggest-food)
        (pause-back)
    elif (eq ?category 2) then
        (suggest-foodplan)
        (pause-back)
    )
)

; ==============================================================================
; ==============================================================================
; ==============================================================================
; ==============================================================================

(reset)
(run)

(bind ?choice -1)
(while (neq ?choice 6)
    (cls)
    (bind ?choice (get-menu))

    (if (eq ?choice 1) then
        (menu-1-view)
    elif (eq ?choice 2) then
        (menu-2-add)
    elif (eq ?choice 3) then
        (menu-3-update)
    elif (eq ?choice 4) then
        (menu-4-delete)
    elif (eq ?choice 5) then
        (menu-5-recommendation)
    )
)
