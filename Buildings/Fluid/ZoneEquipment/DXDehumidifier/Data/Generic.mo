within Buildings.Fluid.ZoneEquipment.DXDehumidifier.Data;
record Generic "Base classes for DX dehumidifier model"
  extends Modelica.Icons.Record;

  constant Integer nWatRem = 6 "Number of coefficients for watRem"
    annotation (Dialog(group="Performance curves"));
  constant Integer nEneFac = 6 "Number of coefficients for eneFac"
    annotation (Dialog(group="Performance curves"));
  parameter Real watRem[nWatRem] = {2.521130E-01,1.324053E-02,-8.637329E-03,8.581056E-02,-4.261176E-03,8.661899E-03} "Biquadratic coefficients for water removal modifier curve"
    annotation (Dialog(group="Performance curves"));
  parameter Real eneFac[nEneFac] = {2.521130E-01,1.324053E-02,-8.637329E-03,8.581056E-02,-4.261176E-03,8.661899E-03} "Biquadratic coefficients for energy factor modifier curve"
    annotation (Dialog(group="Performance curves"));

  annotation (preferredView="info",
  Documentation(info="<html>
<p>This is the base record for the DX dehumidifier. </p>
</html>",
revisions="<html>
<ul>
<li>
July 27, 2016, by Michael Wetter:<br/>
Corrected wrong documentation for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/545\">issue 545</a>.
</li>
<li>
September 15, 2010, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
    Icon(graphics={
        Text(
          extent={{-91,1},{-8,-54}},
          textColor={0,0,255},
          fontSize=16,
          textString="watRem"),
        Text(
          extent={{2,-16},{94,-38}},
          textColor={0,0,255},
          textString="eneFac",
          fontSize=16)}));
end Generic;
