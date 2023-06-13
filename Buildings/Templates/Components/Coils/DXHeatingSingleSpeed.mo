within Buildings.Templates.Components.Coils;
model DXHeatingSingleSpeed "Single speed DX heating coil"
  extends Buildings.Templates.Components.Interfaces.PartialCoil(
    final typ=Buildings.Templates.Components.Types.Coil.DXHeatingSingleSpeed,
    final typVal=Buildings.Templates.Components.Types.Valve.None);

  parameter Boolean have_dryCon = true
    "Set to true for air-cooled condenser, false for evaporative condenser";

  Fluid.HeatExchangers.DXCoils.AirSource.SingleSpeedHeating hex(
    redeclare final package Medium = MediumAir,
    final datCoi=dat.datHeaCoi,
    final dp_nominal=dpAir_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    datDef(QDefResCap=dat.QDefResCap, QCraCap=dat.QCraCap))
    "Heat exchanger"
    annotation (Placement(transformation(extent={{20,-10},{40,10}})));

  Modelica.Blocks.Routing.RealPassThrough TDry if have_dryCon
    annotation (Placement(transformation(extent={{-50,14},{-30,34}})));
  Modelica.Blocks.Routing.RealPassThrough phi if have_dryCon
    annotation (Placement(transformation(extent={{-50,-30},{-30,-10}})));
  Utilities.Psychrometrics.X_pTphi x_pTphi(use_p_in=false)
    annotation (Placement(transformation(extent={{-10,-30},{10,-10}})));
equation
  connect(port_a, hex.port_a)
    annotation (Line(points={{-100,0},{20,0}},  color={0,127,255}));
  connect(hex.port_b, port_b)
    annotation (Line(points={{40,0},{100,0}}, color={0,127,255}));
  connect(busWea.TDryBul, TDry.u) annotation (Line(
      points={{-60,100},{-60,24},{-52,24}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(TDry.y, hex.TOut) annotation (Line(points={{-29,24},{-20,24},{-20,3},
          {19,3}},  color={0,0,127}));
  connect(bus.y1, hex.on) annotation (Line(
      points={{0,100},{0,8},{19,8}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(busWea.relHum, phi.u) annotation (Line(
      points={{-60,100},{-60,-20},{-52,-20}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(x_pTphi.X[1], hex.XOut) annotation (Line(points={{11,-20},{12,-20},{
          12,-9},{19,-9}}, color={0,0,127}));
  connect(phi.y, x_pTphi.phi) annotation (Line(points={{-29,-20},{-22,-20},{-22,
          -26},{-12,-26}}, color={0,0,127}));
  connect(TDry.y, x_pTphi.T) annotation (Line(points={{-29,24},{-20,24},{-20,
          -20},{-12,-20}}, color={0,0,127}));
  annotation (
    Diagram(
        coordinateSystem(preserveAspectRatio=false)), Documentation(info="<html>
<p>
This is a model for a direct expansion cooling coil with a
multi-stage compressor.
The compressor stage is selected with the control
signal <code>y</code> (integer between <code>0</code> and the number
of stages).
</p>
</html>"));
end DXHeatingSingleSpeed;
