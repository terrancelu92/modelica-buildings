within Buildings.Templates.AirHandlersFans.Validation;
model VAVMZCoilDXHeatingSingleSpeed
  "Validation model for multiple-zone VAV"
  extends VAVMZBase(
    datAll(redeclare model VAV =
      UserProject.AirHandlersFans.VAVMZCoilDXHeatingSingleSpeed),
    redeclare
      UserProject.AirHandlersFans.VAVMZCoilDXHeatingSingleSpeed VAV_1);

  annotation (
  experiment(
      StopTime=86400,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),        Documentation(info="<html>
<p>
This is a validation model for the configuration represented by
<a href=\"modelica://Buildings.Templates.AirHandlersFans.Validation.UserProject.AirHandlersFans.VAVMZCoilDXHeatingSingleSpeed\">
Buildings.Templates.AirHandlersFans.Validation.UserProject.AirHandlersFans.VAVMZCoilDXHeatingSingleSpeed</a>
</p>
</html>"));
end VAVMZCoilDXHeatingSingleSpeed;
