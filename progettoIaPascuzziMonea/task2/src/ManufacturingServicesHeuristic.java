import fr.uga.pddl4j.heuristics.state.RelaxedGraphHeuristic;
import fr.uga.pddl4j.planners.statespace.search.Node;
import fr.uga.pddl4j.problem.Problem;
import fr.uga.pddl4j.problem.State;
import fr.uga.pddl4j.problem.operator.Action;
import fr.uga.pddl4j.problem.operator.Condition;

public final class ManufacturingServicesHeuristic extends RelaxedGraphHeuristic {

    public ManufacturingServicesHeuristic(Problem problem) {
        super(problem);
        super.setAdmissible(false);
    }

    @Override
    public int estimate(State state, Condition goal) {
        super.setGoal(goal);
        super.expandRelaxedPlanningGraph(state);
        return super.isGoalReachable() ? 1 : Integer.MAX_VALUE;
    }

    @Override
    public double estimate(Node node, Condition goal) {
        return this.estimate((State) node, goal);
    }

    public double customEstimate(State state, Condition goal, Action a, double currentHeuristic) {
        super.setGoal(goal);
        this.expandRelaxedPlanningGraph(state);

        double heuristicValue = currentHeuristic;

        if(a.getName().contains("move"))
            heuristicValue -= 1;
        else if (a.getName().contains("fill") || a.getName().contains("ws") || a.getName().contains("load") )
            heuristicValue -= 0.8;
        else if (a.getName().equals("empty_box_in_loc"))
            heuristicValue += 0.5;
        return super.isGoalReachable() ? heuristicValue : Integer.MAX_VALUE;
    }
}
