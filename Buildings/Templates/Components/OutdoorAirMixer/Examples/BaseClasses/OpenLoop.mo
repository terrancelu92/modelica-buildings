within Buildings.Templates.Components.OutdoorAirMixer.Examples.BaseClasses;
block OpenLoop "Open loop controller"
  extends
    Buildings.Templates.Components.OutdoorAirMixer.Examples.BaseClasses.PartialVAVMultizone(
      final typ=Buildings.Templates.AirHandlersFans.Types.Controller.OpenLoop);

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yDamOut(k=1)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-180,170})));

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yDamRet(k=1)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-120,170})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yDamRel(k=1)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-90,170})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yCoiCoo(k=1) if coiCoo.typ
     == Buildings.Templates.Components.Types.Coil.WaterBasedCooling or coiCoo.typ
     == Buildings.Templates.Components.Types.Coil.EvaporatorVariableSpeed
     annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-60,110})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant yCoiCooSta(k=1) if
       coiCoo.typ == Buildings.Templates.Components.Types.Coil.EvaporatorMultiStage
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-20,110})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yFanSup(k=1)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={0,70})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant y1FanSup(k=true)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={40,70})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yCoiHea(k=1) if
       coiHeaReh.typ == Buildings.Templates.Components.Types.Coil.ElectricHeating or
       coiHeaReh.typ == Buildings.Templates.Components.Types.Coil.WaterBasedHeating or
       coiHeaPre.typ == Buildings.Templates.Components.Types.Coil.ElectricHeating or
       coiHeaPre.typ == Buildings.Templates.Components.Types.Coil.WaterBasedHeating
    annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={20,110})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yFanRet(k=1)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={160,70})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant y1FanRet(k=true)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={200,70})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant y1CoiHea(k=true) if
       coiHeaReh.typ == Buildings.Templates.Components.Types.Coil.DXHeatingSingleSpeed or
       coiHeaPre.typ == Buildings.Templates.Components.Types.Coil.DXHeatingSingleSpeed
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={70,110})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant yFanRel(k=1)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={80,70})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant y1FanRel(k=true)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={120,70})));
equation
  /* Control point connection - start */

  connect(yCoiCoo.y, bus.coiCoo.y);
  connect(yCoiHea.y, bus.coiHea.y);
  connect(yCoiCooSta.y, bus.coiCoo.y);
  connect(y1CoiHea.y, bus.coiHea.y1);

  connect(y1FanSup.y, bus.fanSup.y1);
  connect(yFanSup.y, bus.fanSup.y);
  connect(y1FanRel.y, bus.fanRel.y1);
  connect(yFanRel.y, bus.fanRel.y);
  connect(y1FanRet.y, bus.fanRet.y1);
  connect(yFanRet.y, bus.fanRet.y);

  connect(yDamOut.y, bus.damOut.y);

  connect(yDamRel.y, bus.damRel.y);
  connect(yDamRet.y, bus.damRet.y);
  /* Control point connection - stop */

  annotation (
  defaultComponentName="conAHU",
  Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<p>
This is an open loop controller providing control inputs
for the templates within
<a href=\"modelica://Buildings.Templates.AirHandlersFans\">
Buildings.Templates.AirHandlersFans</a>.
It is mainly used for testing purposes.
</p>
</html>"));
end OpenLoop;
