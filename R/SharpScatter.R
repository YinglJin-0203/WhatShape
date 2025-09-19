#' Function to visualize SHARP test results
#'
#'
#' @details
#' The shape scatter plot represents the four p-values (corresponding to four shape types) of SHARP test on a 2D space.
#' it can not only visualize the conclusions of the test, but also the confidence level of the test.
#' The plot surface is divided into two parts along two perpendicular directions, corresponding to two opposite shapes.
#' The coordinates of points are derived from p-values such that:
#' * Inconclusive shapes are placed in the center area within the significance thresholds (p > 0.05)
#' * Significant shapes are placed in the edge area out of the significance thresholds (p < 0.05)
#' * The closer points are to the significance thresholds, the more ambiguous shape conclusion is
#'
#'
#' @param pinc,pdec,pconc,pconv SHARP test p-values corresponding to increasing, decreasing, concave and convex
#' @param alpha significance threshold. alpha=NULL corresponding to no significance threshold
#' @param label labels of the point to visualize. label=NULL means no labeling.
#' @param size_point,size_label the size of points and label. size_lable is used when label is not NULL
#' @param ... additional parameters passed to ggplot
#'

SharpScatter <- function(pinc, pdec, pconc, pconv, alpha = 0.05, label = NULL, size_point=2, size_label = 5,...){
  # coordinates for points
  ycoord = 0*(pinc==pdec)+(1-pinc)*(pinc<pdec)+(pdec-1)*(pinc>pdec)
  xcoord = 0*(pconv==pconc)+(pconc<pconv)*(1-pconc)+(pconc>pconv)*(pconv-1)

  # scatter plot
  sharp_scatter <-ggplot(data.frame(xcoord, ycoord), aes(x=xcoord, y=ycoord,...))+
    geom_point(size = size_point)+
    geom_hline(yintercept = 0, linewidth = 1) +  # center y-axis
    geom_vline(xintercept = 0, linewidth = 1) +  # center x-axis
    labs(x=" ", y=" ")+
    theme(panel.grid = element_blank(), axis.text = element_blank(), axis.ticks = element_blank())+
    annotate("text", x = c(-0.9, 0.9), y = c(0,0), label = c("Convex", "Concave"), vjust = 1.1)+
    annotate("text", y = c(-1, 1), x = c(0,0), label = c("Decrease", "Increase"), hjust = 1.1)+
    theme_minimal()

  # visualization threshold
  if(!is.null(alpha)){
    sharp_scatter <- sharp_scatter+
      geom_hline(yintercept = c(1-alpha, -1+alpha), linetype = "dashed", linewidth = 0.5)+
      geom_vline(xintercept = c(1-alpha, -1+alpha), linetype = "dashed", linewidth = 0.5)
  }

  # point label
  if(!is.null(label)){
    sharp_scatter <- sharp_scatter+geom_text(aes(label=label), size = size_label)
  }

 return(sharp_scatter)

}




