// personal assistant agent

/* Task 2 Start of your solution */

/* Initial beliefs about user's wake-up preferences (subtask 3) */
wakeup_ranking(artificial_light, 2).
wakeup_ranking(natural_light, 1).
wakeup_ranking(vibrations, 0).

/* Inference rule to infer best wake-up option (subtask 3 & 5) */
best_option(Method) :- 
    wakeup_ranking(Method, Rank) &
    not used(Method) &
    not (wakeup_ranking(_, Rank2) & Rank2 < Rank & not used(_)).

/* Plans to print relevant messages when beliefs change (subtask 1) */
+owner_state(State) <-
    .print("Owner state updated: ", State).

-owner_state(State) <-
    .print("Owner state removed: ", State).

+lights(State) <-
    .print("Lights state updated: ", State).

-lights(State) <-
    .print("Lights state removed: ", State).

+blinds(State) <-
    .print("Blinds state updated: ", State).

-blinds(State) <-
    .print("Blinds state removed: ", State).

+mattress(State) <-
    .print("Mattress state updated: ", State).

-mattress(State) <-
    .print("Mattress state removed: ", State).

/* Plan for upcoming event (subtask 2 & 4) */
+upcoming_event("now") : owner_state("awake") <-
    .print("Enjoy your event!").

+upcoming_event("now") : owner_state("asleep") <-
    .print("Starting wake-up routine...");
    !wake_up_user.

/* Recursive wake-up plans (subtask 4 & 5) */
+!wake_up_user : owner_state("awake") <-
    .print("Wake-up successful! User is awake.").

+!wake_up_user : owner_state("asleep") & best_option(vibrations) <-
    .print("Waking user by mattress vibrations...");
    setVibrationsMode;
    +used(vibrations);
    .wait(2000);
    !wake_up_user.

+!wake_up_user : owner_state("asleep") & best_option(natural_light) <-
    .print("Waking user by raising blinds...");
    raiseBlinds;
    +used(natural_light);
    .wait(2000);
    !wake_up_user.

+!wake_up_user : owner_state("asleep") & best_option(artificial_light) <-
    .print("Waking user by turning on lights...");
    turnOnLights;
    +used(artificial_light);
    .wait(2000);
    !wake_up_user.

+!wake_up_user : owner_state("asleep") & not best_option(_) <-
    .print("All wake-up methods exhausted. User is still asleep.").

/* Task 2 End of your solution */

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }