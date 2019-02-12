ruleset io.picolabs.temperature_store {
  meta {
    provides temperatures, temperatures_threshold, inrange_temperatures
    shares __testing, temperatures, temperatures_threshold, inrange_temperatures
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    temperatures = function(){
      ent:temperatures.defaultsTo([])
    }
    temperatures_threshold = function(){
      ent:temperatures_threshold.defaultsTo([])
    }
    inrange_temperatures = function(){
      ent:temperatures.defaultsTo([]).filter(function(x){
        not(ent:temperatures_threshold >< x).defaultsTo("")
      })
    }
  }
  
  rule collect_temperatures  {
    select when wovyn new_temperature_reading
    pre{
      temperature = event:attrs{"temperature"}
      timestamp = event:attrs{"timestamp"}
    }
    
    send_directive("new_temperature_reading", {"temperature": temperature, "timestamp": timestamp})
    
    fired{
      ent:temperatures := ent:temperatures.append({"temperature": temperature, "timestamp": timestamp})
    }else{
      
    }
  }
  
  
  rule collect_threshold_violations{
    select when wovyn threshold_violation
    pre{
      temperature = event:attrs{"temperature"}
      timestamp = event:attrs{"timestamp"}
    }
    
    send_directive("collect_threshold_violations", {"temperature": temperature, "timestamp": timestamp})
    
    fired{
      ent:temperatures_threshold := ent:temperatures_threshold.append({"temperature": temperature, "timestamp": timestamp})
    }else{
      
    }
  }
  
  
  rule clear_temeratures  {
    select when sensor reading_reset
      send_directive("reading_reset", {"result": "clearing temperatures"})
    fired{
       ent:temperatures := [];
       ent:temperatures_threshold := [];
    }
  }
  
  
  
  // The following rules were creating for testing purposes:
  
  rule get_temperatures  {
    select when wovyn get_temperatures
      send_directive("get_temperatures", {"temperatures": ent:temperatures})
  }
  
  rule get_temperatures_threshold  {
    select when wovyn get_temperatures_threshold
      send_directive("get_temperatures_threshold", {"temperatures": ent:temperatures_threshold})
  }
  
    rule get_inrange_temperatures  {
    select when wovyn get_inrange_temperatures
      send_directive("get_inrange_temperatures", {"temperatures": inrange_temperatures()})
  }
}
