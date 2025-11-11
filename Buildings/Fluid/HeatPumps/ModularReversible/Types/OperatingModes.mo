within Buildings.Fluid.HeatPumps.ModularReversible.Types;
package OperatingModes
  constant Integer heating = 1 "Heating only";
  constant Integer cooling = 2 "Cooling only";
  constant Integer shc = 3 "Simultaneous heating and cooling";
  annotation(
    Documentation(info="<html>
<p>
This package defines integer constants to specify the operating modes of 
simultaneous heating and cooling systems.
</p>
</html>"));
end OperatingModes;
