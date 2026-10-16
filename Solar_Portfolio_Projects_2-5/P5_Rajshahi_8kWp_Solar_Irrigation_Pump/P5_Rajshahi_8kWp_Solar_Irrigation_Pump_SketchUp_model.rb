# 8.25 kWp Solar Irrigation Pump (7.5 kW) - Rajshahi
# SketchUp 3D model build script. Usage (Ruby Console):
#   load "C:/Users/<you>/Downloads/P5_Rajshahi_8kWp_Solar_Irrigation_Pump_SketchUp_model.rb"
model = Sketchup.active_model
model.start_operation("Build 8.25 kWp solar irrigation pump, Rajshahi", true)
ents = model.active_entities
def mat(model, name, rgb)
  m = model.materials[name] || model.materials.add(name)
  m.color = Sketchup::Color.new(*rgb)
  m
end
def pt(x, y, z) Geom::Point3d.new(x.m, y.m, z.m) end
def box(ents, name, x, y, z, dx, dy, dz, material)
  g = ents.add_group
  g.name = name
  f = g.entities.add_face([pt(x, y, z), pt(x + dx, y, z), pt(x + dx, y + dy, z), pt(x, y + dy, z)])
  f.reverse! if f.normal.z < 0
  f.pushpull(dz.m)
  g.material = material
  g
end
m_pv = mat(model, "PV_module_blue", [31, 58, 107])
m_fr = mat(model, "PV_frame", [190, 190, 190])


def pv_def(model, name, tilt, m_pv, m_fr)
  d = model.definitions[name] || model.definitions.add(name)
  return d if d.entities.length > 0
  w, l = 1.134, 2.278
  dep, h = l * Math.cos(tilt * Math::PI / 180), l * Math.sin(tilt * Math::PI / 180)
  f = d.entities.add_face([pt(0, 0, 0), pt(w, 0, 0), pt(w, dep, h), pt(0, dep, h)])
  f.reverse! if f.normal.z < 0
  f.pushpull(0.035.m)
  d.entities.grep(Sketchup::Face).each { |fc| fc.material = m_fr; fc.back_material = m_fr }
  d.entities.grep(Sketchup::Face).max_by { |fc| fc.bounds.max.z + fc.normal.z }.material = m_pv
  d
end

m_hut = mat(model, "m_hut", [215, 200, 170])
m_obs = mat(model, "m_obs", [150, 150, 150])
m_wat = mat(model, "m_wat", [120, 170, 210])
box(ents, "Controller hut", 2.0, 6.0, 0, 3.0, 3.0, 2.8, m_hut)
box(ents, "Borewell platform", 14.5, 6.0, 0, 1.0, 1.0, 0.6, m_obs)
box(ents, "Discharge chamber", 20.0, 3.0, 0, 3.0, 2.0, 1.0, m_wat)
defn = pv_def(model, "PV_550W_24deg", 24, m_pv, m_fr)
rg = ents.add_group; rg.name = "Row 1 - 15 modules"
15.times { |i| rg.entities.add_instance(defn, Geom::Transformation.new(pt(6.36 + i * 1.154, 12.0, 0.6))) }

si = model.shadow_info
si["City"] = "Rajshahi"; si["Country"] = "Bangladesh"
si["Latitude"] = 24.37; si["Longitude"] = 88.6; si["TZOffset"] = 6.0
si["DisplayShadows"] = true
model.active_view.camera = Sketchup::Camera.new(pt(45, -20, 22), pt(15, 12, 0), Z_AXIS)
# ShadowTime is stored in UTC: local Dhaka time minus 6 h
[["Dec21 09-00", 12, 21, 3], ["Dec21 12-00", 12, 21, 6], ["Dec21 15-00", 12, 21, 9], ["Jun21 07-00", 6, 21, 1]].each do |nm, mo, dy, hr|
  si["ShadowTime"] = Time.gm(2026, mo, dy, hr, 0)
  pg = model.pages[nm] || model.pages.add(nm)
  pg.update
end
model.pages.selected_page = model.pages["Dec21 09-00"]
model.commit_operation
puts "Done: 8.25 kWp solar irrigation pump, Rajshahi"
