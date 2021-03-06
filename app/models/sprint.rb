class Sprint < ActiveModelSerializers::Model
  attr_reader :id, :name, :state, :start_date, :end_date, :complete_date
  attr_accessor :board

  include SprintIssueAbilities

  def initialize(id, name, state, start_date, end_date, complete_date)
    @id, @name, @state, @start_date, @end_date, @complete_date = id, name, state, start_date, end_date, complete_date

    sprint_issue_abilities(self, nil)
  end

  def closed?
    state == 'closed'
  end

  def issues
    @issues ||= Repository.for(:issue).find_by(sprint: self)
  end

  def percentage_closed
    return 0 if points_total == 0

    points_closed / sprint.points_total.to_f * 100
  end


  def sprint_epics
    return @sprint_epics if @sprint_epics

    no_sprint_epic = SprintEpic.new(self, Epic.new('DEV', 'Issues without epic', 0, 'Issues without epic'))

    @sprint_epics = issues.inject([]) do |memo, issue|
      if issue.epic
        sprint_epic = SprintEpic.new(self, issue.epic)
        if memo.include?(sprint_epic)
          sprint_epic = memo[memo.index(sprint_epic)]
        else
          memo << sprint_epic
        end
      else
        sprint_epic = no_sprint_epic
      end
      sprint_epic.issues << issue

      memo
    end

    @sprint_epics << no_sprint_epic if no_sprint_epic.issues.size > 0
    @sprint_epics
  end

  def sprint_parent_epics
    return @sprint_parent_epics if @sprint_parent_epics

    no_sprint_parent_epic = SprintParentEpic.new(self, ParentEpic.new(0, 'DEV', 'Issues without portfolio epic'))

    @sprint_parent_epics = sprint_epics.inject([]) do |memo, sprint_epic|
      if sprint_epic.parent_epic
        sprint_parent_epic = SprintParentEpic.new(self, sprint_epic.parent_epic)
        if memo.include?(sprint_parent_epic)
          sprint_parent_epic = memo[memo.index(sprint_parent_epic)]
        else
          memo << sprint_parent_epic
        end
      else
        sprint_parent_epic = no_sprint_parent_epic
      end
      sprint_parent_epic.issues.concat(sprint_epic.issues)
      memo
    end

    @sprint_parent_epics << no_sprint_parent_epic if no_sprint_parent_epic.issues.size > 0
    @sprint_parent_epics
  end

  def uid
    @uid ||= "#{board_id}_#{id}"
  end

  def board_id
    @board_id ||= board.id
  end

  def ==(sprint)
    self.uid == sprint.uid
  end

  def to_s
    "Sprint: #{name}
     Points:
      closed: #{points_closed}
      open: #{points_open}
      total: #{points_total}
     Issues:
      closed: #{closed_issues.size}
      open: #{open_issues.size}
      total: #{issues.size}"
  end
end
