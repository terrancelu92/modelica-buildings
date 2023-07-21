within Buildings.Templates.AirHandlersFans.Validation;
model VAVMZReliefDamperNoFan "Validation model for multiple-zone VAV"
  extends VAVMZBase(
    datAll(
      _VAV_1(fanSup(m_flow_nominal=1, dp_nominal=500)),
      redeclare model VAV =
        Buildings.Templates.AirHandlersFans.Validation.UserProject.AirHandlersFans.VAVMZReliefDamperNoFan),
    redeclare
      Buildings.Templates.AirHandlersFans.Validation.UserProject.AirHandlersFans.VAVMZReliefDamperNoFan VAV_1);

  annotation (
  experiment(
      StartTime=15552000,
      StopTime=15638400,
      Tolerance=1e-06,
      __Dymola_Algorithm="Dassl"),        Documentation(info="<html>
<p>
This is a validation model for the configuration represented by
<a href=\"modelica://Buildings.Templates.AirHandlersFans.Validation.UserProject.AirHandlersFans.VAVMZFanRelief\">
Buildings.Templates.AirHandlersFans.Validation.UserProject.AirHandlersFans.VAVMZFanRelief</a>
</p>
</html>"));
end VAVMZReliefDamperNoFan;
