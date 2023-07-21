within Buildings.Templates.AirHandlersFans.Validation.UserProject.AirHandlersFans;
model VAVMZReliefDamperNoFan "Configuration of multiple-zone VAV"
  extends Buildings.Templates.AirHandlersFans.VAVMultiZone(
    redeclare replaceable Buildings.Templates.AirHandlersFans.Components.Controls.OpenLoop ctl
      "Open loop controller",
    secOutRel(redeclare replaceable
        Buildings.Templates.AirHandlersFans.Components.ReliefReturnSection.ReliefDamper secRel),
    nZon=2);

  annotation (
    defaultComponentName="ahu", Documentation(info="<html>
<p><br>This is a configuration model with the same default options as <a href=\"modelica://Buildings.Templates.AirHandlersFans.VAVMultiZone\">Buildings.Templates.AirHandlersFans.VAVMultiZone</a> except for the following options.</p>
<table cellspacing=\"2\" cellpadding=\"0\" border=\"1\"><tr>
<td><p align=\"center\"><h4>Component</h4></p></td>
<td><p align=\"center\"><h4>Configuration</h4></p></td>
</tr>
<tr>
<td><p>Relief/return air section</p></td>
<td><p>Relief damper</p></td>
</tr>
<tr>
<td><p>Return fan</p></td>
<td><p>No fan</p></td>
</tr>
<tr>
<td><p>Relief fan</p></td>
<td><p>No fan</p></td>
</tr>
</table>
</html>"));
end VAVMZReliefDamperNoFan;
