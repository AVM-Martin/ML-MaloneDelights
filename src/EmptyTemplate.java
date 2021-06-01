import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Vector;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.table.DefaultTableModel;

import app.*;
import jess.JessException;
import jess.QueryResult;
import jess.ValueVector;

public class EmptyTemplate extends JFrame implements ActionListener{


	/**
	 *
	 */
	private static final long serialVersionUID = 1L;
	JLabel title = new JLabel();
	JButton close = new JButton("Close");

	JScrollPane pane;
	JTable table;
	Vector<Object> tHeader, tRow;

	DefaultTableModel dtm;

	JPanel pnlTable = new JPanel();
	int count;

	public EmptyTemplate(){

		setTitle("The Result of Consultation");
		setSize(500, 200);
		pnlTable.setLayout(new BorderLayout());

		try {

			/* MODIFY Query Result Code Here */
			QueryResult resPlan = Main.engine.runQueryStar("suggest-foodplan", new ValueVector());
			QueryResult resFood = Main.engine.runQueryStar("suggest-food", new ValueVector());

			// Vector contains header for table
			tHeader = new Vector<Object>();

			table = new JTable(dtm) {
				@Override
				public boolean isCellEditable(int arg0, int arg1) {
					return false;
				}
			};

			pane = new JScrollPane(table);
			boolean isPlanExists = resPlan.next();
			boolean isFoodExists = resFood.next();


			if(isPlanExists)
			{
				tHeader.add("Name");
				tHeader.add("Duration");
				tHeader.add("Price");
				tHeader.add("Food Name");
				tHeader.add("Quantity");

				dtm = new DefaultTableModel(tHeader, 0);

				while( isPlanExists )
				{
					//Vector of object to store row data
					tRow = new Vector<Object>();


					/* FILL the blanks string with values from your defquery */
					String planName 		= resPlan.getString("name");
					String planDuration 	= resPlan.getString("duration")+" Day(s)";
					String planPrice 		= "$ " + resPlan.getString("price");
					String planFoodName 	= resPlan.getString("foodname");
					String planFoodQuantity = resPlan.getString("qty");

					tRow.add(planName);
					tRow.add(planDuration);
					tRow.add(planPrice);
					tRow.add(planFoodName);
					tRow.add(planFoodQuantity);

					isPlanExists = resPlan.next();
					dtm.addRow(tRow);
				}

				table.setModel(dtm);

			}else if(isFoodExists){

				tHeader.add("Name");
				tHeader.add("Rating");
				tHeader.add("Price");
				tHeader.add("Type");

				dtm = new DefaultTableModel(tHeader, 0);

				while( isFoodExists )
				{
					//Vector of object to store row data
					tRow = new Vector<Object>();

					/* FILL the blanks string with values from your defquery */
					String foodName 	= resFood.getString("name");
					String foodRating 	= resFood.getString("rating");
					String foodPrice 	= "$" + resFood.getString("price");
					String foodType		= resFood.getString("foodtype");;

					tRow.add(foodName);
					tRow.add(foodRating);
					tRow.add(foodPrice);
					tRow.add(foodType);

					isFoodExists = resFood.next();
					dtm.addRow(tRow);
				}

				table.setModel(dtm);
			}else{
				JOptionPane.showMessageDialog(null, "No Recommendation available!");
				this.dispose();
				return;
			}

			resPlan.close();
			resFood.close();

		} catch (JessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}



		pnlTable.add(pane, BorderLayout.CENTER);

		add(pnlTable, BorderLayout.CENTER);
		add(close,"South");
		close.addActionListener(this);
		setLocationRelativeTo(null);
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setVisible(true);

	}

	@Override
	public void actionPerformed(ActionEvent arg0) {
		// TODO Auto-generated method stub

		if(arg0.getSource()==close)
			this.dispose();

	}
}
