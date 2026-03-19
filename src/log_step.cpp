#include <Rcpp.h>
using namespace Rcpp;

//' Build a single processing log entry
//'
//' @param step    Name of the processing step
//' @param n_cells Number of cells in the object at this step
//' @param n_genes Number of genes in the object at this step
//' @param params  Named list of parameters used in this step
//'
//' @return A named list representing one log entry
//' @keywords internal
// [[Rcpp::export]]
List build_log_entry(
    String    step,
    int       n_cells,
    int       n_genes,
    List      params
) {
  List entry = List::create(
    Named("step")    = step,
    Named("time")    = as<std::string>(Function("as.character")(Function("Sys.time")())),
    Named("n_cells") = n_cells,
    Named("n_genes") = n_genes,
    Named("params")  = params
  );
  return entry;
}


//' Append a log entry to an existing processing log
//'
//' @param log       Existing processing log (a list of entries, may be empty).
//' @param new_entry A single log entry built by \code{build_log_entry}.
//'
//' @return The updated log list with \code{new_entry} appended.
//' @keywords internal
// [[Rcpp::export]]
List append_log_entry(List log, List new_entry) {
  int n = log.size();
  List updated(n + 1);
  for (int i = 0; i < n; i++) {
    updated[i] = log[i];
  }
  updated[n] = new_entry;
  return updated;
}
