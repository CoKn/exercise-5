// illuminance controller agent

/* Initial rules */

// Inference rule for inferring the belief requires_brightening if the target illuminance is higher than the current illuminance
requires_brightening
    :-  target_illuminance(Target) 
        & current_illuminance(Current)
        & (Target - Current) >= 100
.

// Inference rule for inferring the belief requires_darkening if the target illuminance is lower than the current illuminance
requires_darkening
    :-  target_illuminance(Target)  
        & current_illuminance(Current)
        & (Current - Target) >= 100
.

/* Initial beliefs */

// The agent believes that the target illuminance is 350 lux
target_illuminance(350).
lights("off").
blinds("lowered").
weather("sunny").
current_illuminance(0).
managing(false). // Added to manage overlapping actions

/* Initial goals */

// The agent has the initial goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: not already managing illuminance (to avoid overlapping)
 * Body: manages illuminance every 10 seconds to prevent blocking/freezing
*/
@start_plan
+!start
    :   not managing(true)
    <-  .print("Continuously managing illuminance");
        -+managing(true);
        !manage_illuminance; 
        .wait(10000); // Wait sufficient time to avoid artifact blocking issues
        -+managing(false);
        !start;
    .

/* Plan for turning on lights only if blinds are raised or weather is cloudy (avoid conflict with raising blinds) */
@increase_illuminance_with_lights_plan
+!manage_illuminance
    :   lights("off")
        & requires_brightening
        & (blinds("raised") | weather("cloudy"))
    <-
        .print("Turning on the lights");
        turnOnLights;
    .

/* Plan for turning off lights if room requires darkening */
@decrease_illuminance_with_lights_plan
+!manage_illuminance
    :   lights("on")
        & requires_darkening
    <-
        .print("Turning off the lights");
        turnOffLights;
    .

/* Plan for raising blinds only during sunny weather to increase illuminance */
@increase_illuminance_with_blinds_plan
+!manage_illuminance
    :   blinds("lowered")
        & requires_brightening
        & weather("sunny")
    <-
        .print("Raising the blinds (sunny weather)");
        raiseBlinds;
    .

/* Plan for lowering blinds when room requires darkening */
@decrease_illuminance_with_blinds_plan
+!manage_illuminance
    :   blinds("raised")
        & requires_darkening
    <-
        .print("Lowering the blinds");
        lowerBlinds;
    .

/* Plan when the current illuminance equals target illuminance */
@target_reached_plan
+!manage_illuminance
    :   current_illuminance(Current)
        & target_illuminance(Current)
    <-
        .print("Design objective achieved: current illuminance equals target.");
    .

/* Plan reacting to weather becoming cloudy: lower blinds if raised */
@weather_change_lower_blinds_plan
- weather("sunny")
    :   blinds("raised")
    <-
        .print("Weather changed: lowering blinds because it is no longer sunny.");
        lowerBlinds;
    .

/* Plan for reacting to the addition of current illuminance */
@current_illuminance_plan
+current_illuminance(Current)
    :   true
    <-
        .print("Current illuminance level: ", Current);
    .

/* Plan for reacting to the addition of weather condition */
@weather_plan
+weather(State)
    :   true
    <-
        .print("The weather is ", State);
    .

/* Plan for reacting to the addition of blinds state */
@blinds_plan
+blinds(State)
    :   true
    <-
        .print("The blinds are ", State);
    .

/* Plan for reacting to the addition of lights state */
@lights_plan
+lights(State)
    :   true
    <- 
        .print("The lights are ", State);
    .

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }
