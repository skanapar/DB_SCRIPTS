create materialized view mv_well_header
tablespace tobin_test
storage (initial 50m next 5m pctincrease 0)
parallel 4
build immediate
using index tablespace tobin_test_ndx
storage (initial 10m next 1m pctincrease 0)
refresh next round(SYSDATE)+3/24
as
select
	w.uwi,
	n.latitude,
	n.longitude,
	w.pi_rec_upd_date last_activity_date,
	w.operator operator_code,
	ba.ba_name operator_name,
	w.assigned_field field_code,
	w.field_pool_wildcat field_name,
	w.well_name,
	w.well_number,
	w.short_name,
	w.terminating_form formation_code,
	f.form_name formation_name,
	w.spud_date,
	w.pi_comp_date completion_date,
	w.tvd_depth true_vertical_depth,
	w.water_depth,
	w.pi_md measured_depth,
	w.drill_total_depth,
	w.plugback_depth,
	w.pi_log_td log_total_depth,
	w.ref_elev ref_elevation,
	w.elevation_ref elevation_reference_code,
	w.plot_symbol plot_symbol_code,
	rp.plot_symbol_name,
	rp.plot_symbol_group,
	w.lease_name,
	w.lease_number,
	w.initial_class initial_class_code,
	ic.long_name initial_class_name,
	w.class class_code,
	wc.short_name class_name,
	w.pi_crstatus current_status,
	w.pi_final_status final_status_code,
	fs.short_name final_status_name,
	w.deviation_ind deviation_indicator,
	w.hole_direction hole_direction_code,
	pt.long_name hole_direction_name,
	wp.license_number permit_number,
	wp.license_date permit_date,
	w.pi_active_code active_code,
	n.source node_source,
	bn.latitude base_latitude,
	bn.longitude base_longitude
from
	pidm.well@pidm w,
	pidm.well_node@pidm n,
	pidm.well_node@pidm bn,
	pi_codes.business_associate@pidm ba,
	pi_codes.formation@pidm f,
	slm_admin.sde_r_plot_symbol@pidm rp,
	pi_codes.pi_r_initial_class@pidm ic,
	pi_codes.r_well_class@pidm wc,
	pi_codes.pi_r_final_status@pidm fs,
	pi_codes.r_well_profile_typ@pidm pt,
	pidm.well_license@pidm wp
where
	w.surface_node_id = n.node_id(+)
	and w.base_node_id = bn.node_id(+)
	and w.operator = ba.ba_id(+)
	and w.terminating_form = f.form_id(+)
	and w.plot_symbol = rp.plot_symbol_code(+)
	and w.initial_class = ic.initial_class_code(+)
	and w.class = wc.well_class(+)
	and w.pi_final_status = fs.final_status_code(+)
	and w.hole_direction = pt.well_profile_type(+)
	and w.uwi = wp.uwi(+)
/
