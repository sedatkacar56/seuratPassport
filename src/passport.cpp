#include <Rcpp.h>
using namespace Rcpp;

//' Build a passport list from components
//'
//' @param object_id     Name/ID of this Seurat object
//' @param rds_self      RDS registry number of this object
//' @param animal_id     Individual animal identifier
//' @param species       Species name
//' @param sex           Sex of the animal
//' @param age           Age of the animal
//' @param condition     Experimental condition
//' @param tissue        Tissue of origin
//' @param project       Project name
//' @param researcher    Name of the researcher
//' @param date          Date of the experiment
//' @param notes         Free-text notes
//' @param parent_id     Object ID of the direct parent
//' @param rds_parent    RDS number of the parent object
//' @param lineage       Full ancestry chain as character vector
//' @param children      Object IDs of children
//' @param rds_children  RDS numbers of children objects
//' @param custom_keys   Names of custom fields
//' @param custom_vals   Values of custom fields
//'
//' @return A named list representing the passport
//' @keywords internal
// [[Rcpp::export]]
List build_passport(
    String object_id,
    String rds_self,
    String animal_id,
    String species,
    String sex,
    String age,
    String condition,
    String tissue,
    String project,
    String researcher,
    String date,
    String notes,
    String parent_id,
    String rds_parent,
    CharacterVector lineage,
    CharacterVector children,
    CharacterVector rds_children,
    CharacterVector custom_keys,
    CharacterVector custom_vals
) {
  List passport = List::create(
    Named("object_id")    = object_id,
    Named("rds_self")     = rds_self,
    Named("created")      = as<std::string>(Function("as.character")(Function("Sys.time")())),
    Named("animal_id")    = animal_id,
    Named("species")      = species,
    Named("sex")          = sex,
    Named("age")          = age,
    Named("condition")    = condition,
    Named("tissue")       = tissue,
    Named("project")      = project,
    Named("researcher")   = researcher,
    Named("date")         = date,
    Named("notes")        = notes,
    Named("parent_id")    = parent_id,
    Named("rds_parent")   = rds_parent,
    Named("lineage")      = lineage,
    Named("children")     = children,
    Named("rds_children") = rds_children
  );

  // Append custom fields
  int n = custom_keys.size();
  for (int i = 0; i < n; i++) {
    std::string k = as<std::string>(custom_keys[i]);
    std::string v = as<std::string>(custom_vals[i]);
    if (k.size() > 0 && v.size() > 0) {
      passport[k] = v;
    }
  }

  return passport;
}


//' Check whether a passport list is valid
//'
//' @param passport A list (the \code{@misc$passport} slot of a Seurat object).
//' @return TRUE if the passport contains all required fields, FALSE otherwise.
//' @keywords internal
// [[Rcpp::export]]
bool validate_passport(List passport) {
  CharacterVector required = CharacterVector::create(
    "object_id", "rds_self", "created",
    "animal_id", "species", "sex", "age", "condition", "tissue",
    "project", "researcher", "date", "notes",
    "parent_id", "rds_parent", "lineage", "children", "rds_children"
  );

  CharacterVector keys = passport.names();
  for (int i = 0; i < required.size(); i++) {
    bool found = false;
    for (int j = 0; j < keys.size(); j++) {
      if (keys[j] == required[i]) { found = true; break; }
    }
    if (!found) return false;
  }
  return true;
}
