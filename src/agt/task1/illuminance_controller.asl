// illuminance controller agent

/* Initial rules */

// Inference rule for inferring the belief requires_brightening if the target illuminance is higher than the current illuminance
requires_brightening
    :-  target_illuminance(Target) 
        & current_illuminance(Current)
        & Target  > Current
    .

// Inference rule for inferring the belief requires_darkening if the target illuminance is lower than the current illuminance
requires_darkening
    :-  target_illuminance(Target)  
        & current_illuminance(Current)
        & Target < Current
    .

/* Initial beliefs */

// The agent believes that the target illuminance is 350 lux
target_illuminance(350).
lights("off").
blinds("lowered").
weather("sunny").
current_illuminance(0).

/* Initial goals */

// The agent has the initial goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: every 4000ms, the agent strives to maintain the illuminance in the room at the target level 
*/
@start_plan
+!start
    :   true
    <-  .print("Continuously managing illuminance");
        .wait(400);
        !manage_illuminance; // creates the goal !manage_illuminance
        !start;
    .

/* 
 * Plan for reacting to the addition of the goal !manage_illuminance
 * Triggering event: addition of goal !manage_illuminance
 * Context: the agent believes that the lights are off and that the room requires brightening
 * Body: the agent performs the action of turning on the lights
*/
@increase_illuminance_with_lights_plan
+!manage_illuminance
    :   lights("off")
        & requires_brightening
        & (blinds("raised") | weather("cloudy"))
    <-
        .print("Turning on the lights");
        turnOnLights; // performs the action of turning on the lights
    .

/* 
 * Plan for reacting to the addition of the goal !manage_illuminance
 * Triggering event: addition of goal !manage_illuminance
 * Context: the agent believes that the lights are on and that the room requires darkening
 * Body: the agent performs the action of turning off the lights
*/
@decrease_illuminance_with_lights_plan
+!manage_illuminance
    :   lights("on")
        & requires_darkening
    <-
        .print("Turning off the lights");
        turnOffLights; // performs the action of turning off the lights
    .

/* 
 * Plan for reacting to the addition of the goal !manage_illuminance
 * Triggering event: addition of goal !manage_illuminance
 * Context: the agent believes that the blinds are lowered and that the room requires brightening
 * Body: the agent performs the action of raising the blinds
*/
@increase_illuminance_with_blinds_plan
+!manage_illuminance
    :   blinds("lowered")
        &  requires_brightening
        & weather("sunny")
    <-
        .print("Raising the blinds");
        raiseBlinds; // performs the action of raising the blinds
    .

/* 
 * Plan for reacting to the addition of the goal !manage_illuminance
 * Triggering event: addition of goal !manage_illuminance
 * Context: the agent believes that the blinds are raised and that the room requires darkening
 * Body: the agent performs the action of lowering the blinds
*/
@decrease_illuminance_with_blinds_plan
+!manage_illuminance
    :   blinds("raised")
        & requires_darkening
    <-
        .print("Lowering the blinds");
        lowerBlinds; // performs the action of lowering the blinds
    .

/* Plan reacting to weather becoming cloudy: lower blinds if raised */
@weather_change_lower_blinds_plan
- weather("sunny")
    :   blinds("raised")
    <-
        .print("Weather changed: lowering blinds because it is no longer sunny.");
        lowerBlinds;
    .

/* 
 * Plan for reacting to the addition of the belief current_illuminance(Current)
 * Triggering event: addition of belief current_illuminance(Current)
 * Context: true (the plan is always applicable)
 * Body: prints the current illuminance conditions in the room
*/
@current_illuminance_plan
+current_illuminance(Current)
    :   true
    <-
        .print("Current illuminance level: ", Current)
    .

/* 
 * Plan for reacting to the addition of the belief weather(State)
 * Triggering event: addition of belief weather(State)
 * Context: true (the plan is always applicable)
 * Body: prints the weather conditions
*/
@weather_plan
+weather(State)
    :   true
    <-
        .print("The weather is ", State);
    .

/* 
 * Plan for reacting to the addition of the belief blinds(State)
 * Triggering event: addition of belief blinds(State)
 * Context: true (the plan is always applicable)
 * Body: prints the state of the blinds
*/
@blinds_plan
+blinds(State)
    : true
    <-
        .print("The blinds are ", State);
    .

/* 
 * Plan for reacting to the addition of the belief lights(State)
 * Triggering event: addition of belief lights(State)
 * Context: true (the plan is always applicable)
 * Body: prints the state of the lights
*/
@lights_plan
+lights(State)
    : true
    <- 
        .print("The lights are ", State);
    .

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }