within Buildings.Fluid.HeatExchangers.DXCoils.BaseClasses;
partial model PartialDXCoolingCoil "Partial model for DX cooling coil"
  extends Buildings.Fluid.HeatExchangers.DXCoils.BaseClasses.PartialDXCoil(
    final activate_CooCoi=true,
    redeclare Buildings.Fluid.HeatExchangers.DXCoils.BaseClasses.DXCooling
      dxCoi(redeclare package Medium = Medium),
    redeclare final Buildings.Fluid.MixingVolumes.MixingVolumeMoistAir vol(
      prescribedHeatFlowRate=true));

protected
  Modelica.Blocks.Sources.RealExpression X(final y=XIn[i_x])
    "Inlet air mass fraction"
    annotation (Placement(transformation(extent={{-56,24},{-36,44}})));
  Modelica.Blocks.Sources.RealExpression h(final y=hIn)
    "Inlet air specific enthalpy"
    annotation (Placement(transformation(extent={{-56,10},{-36,30}})));
  Modelica.Blocks.Sources.RealExpression p(final y=port_a.p)
    "Inlet air pressure"
    annotation (Placement(transformation(extent={{-90,2},{-70,22}})));
equation
  connect(p.y,dxCoi.p)  annotation (Line(points={{-69,12},{-58,12},{-58,49.6},{
          -21,49.6}}, color={0,0,127}));
  connect(dxCoi.SHR, pwr.SHR) annotation (Line(points={{1,52},{12,52},{12,64},{
          18,64}}, color={0,0,127}));
  connect(dxCoi.mWat_flow, eva.mWat_flow) annotation (Line(
      points={{1,44},{8,44},{8,8},{-22,8},{-22,-70},{-10,-70}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(pwr.QLat_flow, QLat_flow) annotation (Line(points={{41,64},{80,64},{80,
          50},{110,50}}, color={0,0,127}));
  connect(X.y,dxCoi.XEvaIn)  annotation (Line(points={{-35,34},{-32,34},{-32,47},
          {-21,47}}, color={0,0,127}));
  connect(h.y,dxCoi.hEvaIn)  annotation (Line(points={{-35,20},{-28,20},{-28,
          44.3},{-21,44.3}}, color={0,0,127}));
  connect(T.y,dxCoi.TEvaIn)  annotation (Line(points={{-69,28},{-62,28},{-62,52},
          {-21,52}}, color={0,0,127}));
  connect(vol.X_w, eva.XEvaOut) annotation (Line(
      points={{13,-6},{40,-6},{40,-90},{-4,-90},{-4,-82}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(TOut,dxCoi.TConIn)  annotation (Line(points={{-110,30},{-92,30},{-92,
          57},{-21,57}}, color={0,0,127}));
  connect(eva.mTotWat_flow, vol.mWat_flow) annotation (Line(points={{13,-70},{22,
          -70},{22,-42},{-20,-42},{-20,-18},{-11,-18}}, color={0,0,127}));
  annotation (
defaultComponentName="dxCoi",
Documentation(info="<html>
<p>
This partial model is the base class for
<a href=\"modelica://Buildings.Fluid.HeatExchangers.DXCoils.AirSource.SingleSpeedCooling\">
Buildings.Fluid.HeatExchangers.DXCoils.AirSource.SingleSpeedCooling</a>,
<a href=\"modelica://Buildings.Fluid.HeatExchangers.DXCoils.AirSource.MultiStageCooling\">
Buildings.Fluid.HeatExchangers.DXCoils.AirSource.MultiStageCooling</a> and
<a href=\"modelica://Buildings.Fluid.HeatExchangers.DXCoils.AirSource.VariableSpeedCooling\">
Buildings.Fluid.HeatExchangers.DXCoils.AirSource.VariableSpeedCooling</a>.
</p>
</html>",
revisions="<html>
<ul>
<li>
March 19, 2023 by Xing Lu and Karthik Devaprasad:<br/>
First implementation.
</li>
</ul>
</html>"),
    Icon(graphics={Text(
          extent={{-138,64},{-80,46}},
          textColor={0,0,127},
          textString="TConIn"), Text(
          extent={{58,98},{102,78}},
          textColor={0,0,127},
          textString="P"),      Text(
          extent={{54,60},{98,40}},
          textColor={0,0,127},
          textString="QLat"),   Text(
          extent={{54,80},{98,60}},
          textColor={0,0,127},
          textString="QSen")}));
end PartialDXCoolingCoil;