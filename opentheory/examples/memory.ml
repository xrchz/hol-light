(* ------------------------------------------------------------------------- *)
(* Memory safety for the H interface.                                        *)
(* ------------------------------------------------------------------------- *)

logfile "memory-def";;

(* Physical pages *)

new_type_abbrev("region_length",`:num`);;

new_type_abbrev("superpage_address",`:word10`);;

new_type_abbrev("superpage_offset",`:word10`);;

new_type_abbrev("offset",`:word12`);;

new_type_abbrev("physical_page_address",
                `:superpage_address # superpage_offset`);;

new_type_abbrev("physical_address",`:physical_page_address # offset`);;

new_type_abbrev("page_data",`:offset -> byte`);;

(* Page directories *)

new_type_abbrev("page_directory",`:physical_page_address`);;

new_type_abbrev("page_directory_index",`:superpage_address`);;  (*** JEH ***)

let directory_contents_induct,directory_contents_recursion = define_type
    "directory_contents =
       Superpage superpage_address
     | Table physical_page_address";;

export_thm directory_contents_induct;;
export_thm directory_contents_recursion;;

new_type_abbrev("directory_page_data",
                `:page_directory_index -> directory_contents option`);;

(* Page tables *)

new_type_abbrev("page_table_index",`:superpage_offset`);;  (*** JEH ***)

new_type_abbrev("table_page_data",
                `:page_table_index -> physical_page_address option`);;

(* Virtual pages *)

new_type_abbrev("virtual_page_address",
                `:page_directory_index # page_table_index`);;

new_type_abbrev("virtual_address",`:virtual_page_address # offset`);;

(* Page types *)

let page_induct,page_recursion = define_type
    "page =
       Environment page_data
     | Normal page_data
     | PageDirectory directory_page_data
     | PageTable table_page_data";;

export_thm page_induct;;
export_thm page_recursion;;

(* Regions of physical memory *)

let physical_region_induct,physical_region_recursion = define_type
    "physical_region =
       PhysicalRegion
         physical_page_address
         region_length";;

export_thm physical_region_induct;;
export_thm physical_region_recursion;;

let physical_region_start_def =
  new_recursive_definition physical_region_recursion
  `!s l. physical_region_start (PhysicalRegion s l) = s`;;

export_thm physical_region_start_def;;

let physical_region_length_def =
  new_recursive_definition physical_region_recursion
  `!s l. physical_region_length (PhysicalRegion s l) = l`;;

export_thm physical_region_length_def;;

(* Regions of virtual memory *)

let virtual_region_induct,virtual_region_recursion = define_type
    "virtual_region =
       VirtualRegion
         virtual_page_address
         region_length";;

export_thm virtual_region_induct;;
export_thm virtual_region_recursion;;

let virtual_region_start_def =
  new_recursive_definition virtual_region_recursion
  `!s l. virtual_region_start (VirtualRegion s l) = s`;;

export_thm virtual_region_start_def;;

let virtual_region_length_def =
  new_recursive_definition virtual_region_recursion
  `!s l. virtual_region_length (VirtualRegion s l) = l`;;

export_thm virtual_region_length_def;;

(* The state of the machine *)

let region_state_induct,region_state_recursion = define_type
    "region_state =
       RegionState
         (physical_region -> bool)
         (physical_region -> bool)";;

export_thm region_state_induct;;
export_thm region_state_recursion;;

let initial_regions_def = new_recursive_definition region_state_recursion
  `!i a. initial_regions (RegionState i a) = i`;;

export_thm initial_regions_def;;

let all_regions_def = new_recursive_definition region_state_recursion
  `!i a. all_regions (RegionState i a) = a`;;

export_thm all_regions_def;;

let state_induct,state_recursion = define_type
    "state =
       State
         page_directory
         page_directory
         (physical_page_address -> page)
         region_state";;

export_thm state_induct;;
export_thm state_recursion;;

let cr3_def = new_recursive_definition state_recursion
  `!c r s g. cr3 (State c r s g) = c`;;

export_thm cr3_def;;

let reference_def = new_recursive_definition state_recursion
  `!c r s g. reference (State c r s g) = r`;;

export_thm reference_def;;

let status_def = new_recursive_definition state_recursion
  `!c r s g. status (State c r s g) = s`;;

export_thm status_def;;

let regions_def = new_recursive_definition state_recursion
  `!c r s g. regions (State c r s g) = g`;;

export_thm regions_def;;

(* Protection domains *)

let domain_induct,domain_recursion = define_type
    "domain =
       EDomain
     | HDomain
     | KDomain
     | UDomain";;

export_thm domain_induct;;
export_thm domain_recursion;;

let action_induct,action_recursion = define_type
    "action =
       WriteE virtual_address byte
     | DeriveRegionH physical_region physical_page_address region_length
     | AllocatePageDirectoryH physical_page_address
     | FreePageDirectoryH page_directory
     | AddMappingH
         page_directory (physical_page_address list)
         physical_region virtual_region
     | RemoveMappingH page_directory virtual_region
     | AddKernelMappingH physical_region virtual_region
     | ExecuteH page_directory
     | WriteK virtual_address byte
     | WriteU virtual_address byte";;

export_thm action_induct;;
export_thm action_recursion;;

let e_view_induct,e_view_recursion = define_type
    "e_view =
       EView (virtual_page_address -> page_data option)";;

export_thm e_view_induct;;
export_thm e_view_recursion;;

let e_observable_pages_def = new_recursive_definition e_view_recursion
  `!f. e_observable_pages (EView f) = f`;;

export_thm e_observable_pages_def;;

let h_view_induct,h_view_recursion = define_type
    "h_view =
       HView
         page_directory
         (physical_page_address -> page option)
         region_state
         page_directory";;

export_thm h_view_induct;;
export_thm h_view_recursion;;

let current_pdir_def = new_recursive_definition h_view_recursion
  `!c p g r. current_pdir (HView c p g r) = c`;;

export_thm current_pdir_def;;

let pages_def = new_recursive_definition h_view_recursion
  `!c p g r. pages (HView c p g r) = p`;;

export_thm pages_def;;

let h_region_handles_def = new_recursive_definition h_view_recursion
  `!c p g r. h_region_handles (HView c p g r) = g`;;

export_thm h_region_handles_def;;

let reference_pdir_def = new_recursive_definition h_view_recursion
  `!c p g r. reference_pdir (HView c p g r) = r`;;

export_thm reference_pdir_def;;

let k_view_induct,k_view_recursion = define_type
    "k_view =
       KView
         (virtual_page_address -> page_data option)
         region_state";;

export_thm k_view_induct;;
export_thm k_view_recursion;;

let k_observable_pages_def = new_recursive_definition k_view_recursion
  `!f g. k_observable_pages (KView f g) = f`;;

export_thm k_observable_pages_def;;

let k_region_handles_def = new_recursive_definition k_view_recursion
  `!f g. k_region_handles (KView f g) = g`;;

export_thm k_region_handles_def;;

let u_view_induct,u_view_recursion = define_type
    "u_view =
       UView (virtual_page_address -> page_data option)";;

export_thm u_view_induct;;
export_thm u_view_recursion;;

let u_observable_pages_def = new_recursive_definition u_view_recursion
  `!f. u_observable_pages (UView f) = f`;;

export_thm u_observable_pages_def;;

let view_induct,view_recursion = define_type
    "view =
       ViewE e_view
     | ViewH h_view
     | ViewK k_view
     | ViewU u_view";;

export_thm view_induct;;
export_thm view_recursion;;

new_type_abbrev("output",`:view`);;

logfile "memory-thm";;

(* Physical pages *)

(* Page directories *)

let directory_contents_cases = prove_cases_thm directory_contents_induct;;

export_thm directory_contents_cases;;

let directory_contents_distinct = distinctness "directory_contents";;

export_thm directory_contents_distinct;;

let directory_contents_inj = injectivity "directory_contents";;

export_thm directory_contents_inj;;

(* Page tables *)

(* Pages *)

let page_cases = prove_cases_thm page_induct;;

export_thm page_cases;;

let page_distinct = distinctness "page";;

export_thm page_distinct;;

let page_inj = injectivity "page";;

export_thm page_inj;;

(* Regions of physical memory *)

let physical_region_cases = prove_cases_thm physical_region_induct;;

export_thm physical_region_cases;;

let physical_region_inj = injectivity "physical_region";;

export_thm physical_region_inj;;

(* Regions of virtual memory *)

let virtual_region_cases = prove_cases_thm virtual_region_induct;;

export_thm virtual_region_cases;;

let virtual_region_inj = injectivity "virtual_region";;

export_thm virtual_region_inj;;

(* The state of the machine *)

let region_state_cases = prove_cases_thm region_state_induct;;

export_thm region_state_cases;;

let region_state_inj = injectivity "region_state";;

export_thm region_state_inj;;

let state_cases = prove_cases_thm state_induct;;

export_thm state_cases;;

let state_inj = injectivity "state";;

export_thm state_inj;;

(* Protection domains *)

let domain_cases = prove_cases_thm domain_induct;;

export_thm domain_cases;;

let domain_distinct = distinctness "domain";;

export_thm domain_distinct;;

let action_cases = prove_cases_thm action_induct;;

export_thm action_cases;;

let action_distinct = distinctness "action";;

export_thm action_distinct;;

let action_inj = injectivity "action";;

export_thm action_inj;;

let e_view_cases = prove_cases_thm e_view_induct;;

export_thm e_view_cases;;

let e_view_inj = injectivity "e_view";;

export_thm e_view_inj;;

let h_view_cases = prove_cases_thm h_view_induct;;

export_thm h_view_cases;;

let h_view_inj = injectivity "h_view";;

export_thm h_view_inj;;

let k_view_cases = prove_cases_thm k_view_induct;;

export_thm k_view_cases;;

let k_view_inj = injectivity "k_view";;

export_thm k_view_inj;;

let u_view_cases = prove_cases_thm u_view_induct;;

export_thm u_view_cases;;

let u_view_inj = injectivity "u_view";;

export_thm u_view_inj;;

let view_cases = prove_cases_thm view_induct;;

export_thm view_cases;;

let view_distinct = distinctness "view";;

export_thm view_distinct;;

let view_inj = injectivity "view";;

export_thm view_inj;;

logfile_end ();;
