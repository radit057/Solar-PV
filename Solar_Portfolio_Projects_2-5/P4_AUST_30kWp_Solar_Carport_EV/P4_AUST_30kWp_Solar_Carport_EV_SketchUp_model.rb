# 29.7 kWp Solar Carport with EV Charging - AUST Campus, Tejgaon
# SketchUp 3D model build script. Usage (Ruby Console):
#   load "C:/Users/<you>/Downloads/P4_AUST_30kWp_Solar_Carport_EV_SketchUp_model.rb"
model = Sketchup.active_model
model.start_operation("Build 29.7 kWp solar carport + EV charging", true)
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

m_col = mat(model, "m_col", [120, 120, 125])
m_ev = mat(model, "m_ev", [40, 140, 90])
m_inv = mat(model, "m_inv", [200, 200, 200])
box(ents, "Column C1", 2.6300000000000003, 4.85, 0, 0.3, 0.3, 2.7, m_col)
box(ents, "Column C2", 10.24, 4.85, 0, 0.3, 0.3, 2.7, m_col)
box(ents, "Column C3", 17.85, 4.85, 0, 0.3, 0.3, 2.7, m_col)
box(ents, "Column C4", 25.460000000000004, 4.85, 0, 0.3, 0.3, 2.7, m_col)
box(ents, "Column C5", 33.07, 4.85, 0, 0.3, 0.3, 2.7, m_col)
box(ents, "Column C6", 2.6300000000000003, 9.35, 0, 0.3, 0.3, 3.493, m_col)
box(ents, "Column C7", 10.24, 9.35, 0, 0.3, 0.3, 3.493, m_col)
box(ents, "Column C8", 17.85, 9.35, 0, 0.3, 0.3, 3.493, m_col)
box(ents, "Column C9", 25.460000000000004, 9.35, 0, 0.3, 0.3, 3.493, m_col)
box(ents, "Column C10", 33.07, 9.35, 0, 0.3, 0.3, 3.493, m_col)
box(ents, "EV charger 1", 14.0, 10.1, 0, 0.6, 0.4, 1.5, m_ev)
box(ents, "EV charger 2", 18.0, 10.1, 0, 0.6, 0.4, 1.5, m_ev)
box(ents, "Inverter + AC DB", 33.0, 10.1, 0, 1.6, 0.6, 1.8, m_inv)
defn = pv_def(model, "PV_550W_10deg", 10, m_pv, m_fr)
rg = ents.add_group; rg.name = "Row 1 - 27 modules"
27.times { |i| rg.entities.add_instance(defn, Geom::Transformation.new(pt(2.43 + i * 1.154, 5.0, 2.7))) }
rg = ents.add_group; rg.name = "Row 2 - 27 modules"
27.times { |i| rg.entities.add_instance(defn, Geom::Transformation.new(pt(2.43 + i * 1.154, 7.2633920613618095, 3.099))) }

si = model.shadow_info
si["City"] = "Dhaka"; si["Country"] = "Bangladesh"
si["Latitude"] = 23.76; si["Longitude"] = 90.41; si["TZOffset"] = 6.0
si["DisplayShadows"] = true
model.active_view.camera = Sketchup::Camera.new(pt(55, -25, 22), pt(18, 7, 2), Z_AXIS)
# ShadowTime is stored in UTC: local Dhaka time minus 6 h
[["Dec21 09-00", 12, 21, 3], ["Dec21 12-00", 12, 21, 6], ["Dec21 15-00", 12, 21, 9], ["Jun21 07-00", 6, 21, 1]].each do |nm, mo, dy, hr|
  si["ShadowTime"] = Time.gm(2026, mo, dy, hr, 0)
  pg = model.pages[nm] || model.pages.add(nm)
  pg.update
end
model.pages.selected_page = model.pages["Dec21 09-00"]
model.commit_operation
puts "Done: 29.7 kWp solar carport + EV charging"
