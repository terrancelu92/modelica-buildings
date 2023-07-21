within Buildings.Templates.Components.OutdoorAirMixer.Interfaces;
partial model PartialOutdoorAirMixer
  "Interface class for outdoor air mixer"

  replaceable package MediumAir=Buildings.Media.Air
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Air medium"
    annotation(__Linkage(enable=false));
  parameter Buildings.Templates.Components.Types.Damper typDamOut
    "Outdoor air damper type"
    annotation (Evaluate=true, Dialog(group="Configuration"));
  parameter Buildings.Templates.Components.Types.Damper typDamRel
    "Relief damper type"
    annotation (Evaluate=true, Dialog(group="Configuration"));
  parameter Buildings.Templates.Components.Types.Damper typDamRet
    "Return damper type"
    annotation (Evaluate=true, Dialog(group="Configuration"));

  parameter Boolean have_eco = false
    "Set to true in case of economizer function"
    annotation (Evaluate=true, Dialog(group="Configuration"));
  inner parameter Boolean have_recHea = false
    "Set to true in case of heat recovery"
    annotation (Evaluate=true,
      Dialog(group="Configuration"));

  inner parameter Buildings.Controls.OBC.ASHRAE.G36.Types.ControlEconomizer typCtlEco=
    Buildings.Controls.OBC.ASHRAE.G36.Types.ControlEconomizer.FixedDryBulb
    "Economizer control type"
    annotation (Evaluate=true,
      Dialog(
        group="Configuration",
        enable=have_eco));

  parameter
    Buildings.Templates.AirHandlersFans.Components.Data.OutdoorReliefReturnSection
    dat(
      final typDamOut=typDamOut,
      final typDamRet=typDamRet,
      final typDamRel=typDamRel,
      final typDamOutMin=Buildings.Templates.Components.Types.Damper.None,
      final typFanRel=Buildings.Templates.Components.Types.Fan.None,
      final typFanRet=Buildings.Templates.Components.Types.Fan.None)
    "Design and operating parameters";

  final parameter Modelica.Units.SI.MassFlowRate mAirSup_flow_nominal=
    dat.damOut.m_flow_nominal
    "Supply air mass flow rate";
  final parameter Modelica.Units.SI.MassFlowRate mAirRet_flow_nominal=
    dat.damRet.m_flow_nominal
    "Return air mass flow rate";
  final parameter Modelica.Units.SI.MassFlowRate mOutMin_flow_nominal=
    dat.mOutMin_flow_nominal
    "Minimum outdoor air mass flow rate at design conditions";

  final parameter Modelica.Units.SI.PressureDifference dpDamOut_nominal=
    dat.damOut.dp_nominal
    "Outdoor air damper pressure drop";
  final parameter Modelica.Units.SI.PressureDifference dpDamOutMin_nominal=
    dat.damOutMin.dp_nominal
    "Minimum outdoor air damper pressure drop";
  final parameter Modelica.Units.SI.PressureDifference dpDamRel_nominal=
    dat.damRel.dp_nominal
    "Relief air damper pressure drop";
  final parameter Modelica.Units.SI.PressureDifference dpDamRet_nominal=
    dat.damRet.dp_nominal
    "Return air damper pressure drop";

  parameter Boolean allowFlowReversal = true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal"
    annotation(Dialog(tab="Assumptions"), Evaluate=true, __Linkage(enable=false));

  Modelica.Fluid.Interfaces.FluidPort_b port_Rel(
    redeclare final package Medium = MediumAir,
    m_flow(max=if allowFlowReversal then +Modelica.Constants.inf else 0),
    h_outflow(start=MediumAir.h_default, nominal=MediumAir.h_default))
    "Relief (exhaust) air"
    annotation (Placement(transformation(
      extent={{-190,70},{-170,90}}),iconTransformation(extent={{-810,590},{-790,
            610}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_Out(
    redeclare final package Medium = MediumAir,
    m_flow(min=if allowFlowReversal then -Modelica.Constants.inf else 0),
    h_outflow(start=MediumAir.h_default, nominal=MediumAir.h_default))
    "Outdoor air intake"
    annotation (Placement(transformation(
      extent={{-190,-90},{-170,-70}}),iconTransformation(extent={{-810,-610},{-790,
            -590}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_Sup(
    redeclare final package Medium = MediumAir,
    m_flow(max=if allowFlowReversal then +Modelica.Constants.inf else 0),
    h_outflow(start=MediumAir.h_default, nominal=MediumAir.h_default))
    "Supply air"
    annotation (
      Placement(transformation(extent={{170,-90},{190,-70}}),
        iconTransformation(extent={{790,-610},{810,-590}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_Ret(
    redeclare final package Medium =MediumAir,
    m_flow(min=if allowFlowReversal then -Modelica.Constants.inf else 0),
    h_outflow(start=MediumAir.h_default, nominal=MediumAir.h_default))
    "Return air"
    annotation (Placement(transformation(extent={{170,70},{190,90}}),
        iconTransformation(extent={{790,588},{810,608}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_bPre(
    redeclare final package Medium = MediumAir)
    "Optional fluid connector for differential pressure sensor"
    annotation (Placement(transformation(extent={{90,130},{70,150}}),
        iconTransformation(extent={{390,790},{370,810}})));
  Buildings.Templates.AirHandlersFans.Interfaces.Bus bus "Control bus"
    annotation (Placement(
      transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={0,140}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={0,800})));

  annotation (Icon(coordinateSystem(preserveAspectRatio=false,
    extent={{-800,-800}, {800,800}}),
    graphics={
      Text(
          extent={{-149,-834},{151,-874}},
          textColor={0,0,255},
          textString="%name"),
      Bitmap(
        visible=typDamRel==Buildings.Templates.Components.Types.Damper.TwoPosition,
        extent={{-680,360},{-600,440}},
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Actuators/TwoPosition.svg"),
      Bitmap(
        visible=typDamRel==Buildings.Templates.Components.Types.Damper.Modulating,
        extent={{-680,360},{-600,440}},
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Actuators/Modulating.svg"),
              Bitmap(
        extent={{-600,440},{-680,700}},
        visible=typDamRel<>Buildings.Templates.Components.Types.Damper.None,
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Dampers/BladesOpposed.svg"),
      Bitmap(
        visible=typ<>Buildings.Templates.AirHandlersFans.Types.OutdoorReliefReturnSection.HundredPctOutdoorAir,
        extent={{-240,-40},{-160,40}},
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Actuators/Modulating.svg"),
      Bitmap(
        extent={{-40,-130},{40,130}},
        visible=typ<>Buildings.Templates.AirHandlersFans.Types.OutdoorReliefReturnSection.HundredPctOutdoorAir,
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Dampers/BladesParallel.svg",
          origin={-30,-1.42109e-14},
          rotation=-90),
      Bitmap(
        extent={{-680,-760},{-600,-500}},
        visible=typDamOut<>Buildings.Templates.Components.Types.Damper.None,
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Dampers/BladesParallel.svg"),
      Bitmap(
        visible=typDamOut==Buildings.Templates.Components.Types.Damper.TwoPosition,
        extent={{-680,-840},{-600,-760}},
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Actuators/TwoPosition.svg"),
      Bitmap(
        visible=typSecOut==Buildings.Controls.OBC.ASHRAE.G36.Types.OutdoorAirSection.SingleDamper,
        extent={{-202,-760},{-100,-500}},
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Sensors/VolumeFlowRateAFMS.svg"),
      Bitmap(
        visible=typDamOut==Buildings.Templates.Components.Types.Damper.Modulating,
        extent={{-680,-840},{-600,-760}},
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Actuators/Modulating.svg"),
      Line(points={{-100,700},{800,700}}, color={0,0,0}),
      Line(
        visible=typ <> Buildings.Templates.AirHandlersFans.Types.OutdoorReliefReturnSection.MixedAirNoRelief,
        points={{-800,500},{-100,500}},
        color={0,0,0}),
      Line(points={{96,500},{796,500}}, color={0,0,0}),
      Line(points={{100,-500},{800,-500}},color={0,0,0}),
      Line(points={{-800,-500},{-100,-500}},color={0,0,0}),
      Line(points={{-800,-700},{800,-700}}, color={0,0,0}),
      Line(
        visible=typ <> Buildings.Templates.AirHandlersFans.Types.OutdoorReliefReturnSection.HundredPctOutdoorAir,
        points={{100,500},{100,-500}},
        color={0,0,0}),
      Line(
          visible=typ <> Buildings.Templates.AirHandlersFans.Types.OutdoorReliefReturnSection.HundredPctOutdoorAir,
          points={{-100,500},{-100,-500}},
          color={0,0,0}),
      Line(
        points={{-800,700},{-100,700}},
        color={0,0,0},
        visible=typ <> Buildings.Templates.AirHandlersFans.Types.OutdoorReliefReturnSection.MixedAirNoRelief),
      Bitmap(
        visible=true,
        extent={{-194,-840},{-106,-760}},
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Sensors/VolumeFlowRate.svg"),
      Bitmap(
        visible=true,
        extent={{-306,-760},{-286,-560}},
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Sensors/ProbeStandard.svg"),
      Bitmap(
        visible=true,
        extent={{-336,-840},{-256,-760}},
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Sensors/Temperature.svg"),
      Bitmap(
        visible=
          (typCtlEco==Buildings.Controls.OBC.ASHRAE.G36.Types.ControlEconomizer.FixedEnthalpyWithFixedDryBulb or
          typCtlEco==Buildings.Controls.OBC.ASHRAE.G36.Types.ControlEconomizer.DifferentialEnthalpyWithFixedDryBulb),
        extent={{-426,-760},{-406,-560}},
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Sensors/ProbeStandard.svg"),
      Bitmap(
        visible=
          (typCtlEco==Buildings.Controls.OBC.ASHRAE.G36.Types.ControlEconomizer.FixedEnthalpyWithFixedDryBulb or
          typCtlEco==Buildings.Controls.OBC.ASHRAE.G36.Types.ControlEconomizer.DifferentialEnthalpyWithFixedDryBulb),
        extent={{-456,-840},{-376,-760}},
        fileName="modelica://Buildings/Resources/Images/Templates/Components/Sensors/SpecificEnthalpy.svg")}),
   Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-180,-140},{180,140}})),
    Documentation(info="<html>
<p>
This class provides a standard interface for the outdoor/relief/return
air section of an air handler.
Typical components in that section include
</p>
<ul>
<li>
shut off dampers,
</li>
<li>
the heat recovery unit,
</li>
<li>
the air economizer,
</li>
<li>
the relief or return fan.
</li>
</ul>
</html>"));

end PartialOutdoorAirMixer;
